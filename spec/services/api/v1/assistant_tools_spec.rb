# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assistant tools" do
  let(:organization) { create(:organization, plan: "enterprise") }
  let(:admin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
    end
  end

  before { AuthMatrix::Initializer.setup_workspace!(organization) }

  def run(tool, **args)
    result = nil
    references = Api::V1::Assistant::Context.with(organization: organization, user: admin) do
      Api::V1::Assistant::References.collect do
        result = tool.new.execute(**args)
      end
    end

    [ result, references ]
  end

  describe Api::V1::Assistant::Tools::FindUsers do
    it "filters unconfirmed users and records references" do
      ActsAsTenant.with_tenant(organization) do
        pending_user = build(:user, :unconfirmed, first_name: "Pending")
        pending_user.skip_confirmation_notification!
        pending_user.save!
        create(:user, first_name: "Confirmed")
      end

      result, references = run(described_class, confirmed: false, limit: 5, order: "recent")

      expect(result.map { |row| row[:name] }).to include(a_string_starting_with("Pending"))
      expect(result.map { |row| row[:confirmed] }).to all(be(false))
      expect(references.first["type"]).to eq("user")
      expect(references.first["href"]).to eq("/users")
    end
  end

  describe Api::V1::Assistant::Tools::CountUsers do
    it "counts users by confirmation status" do
      ActsAsTenant.with_tenant(organization) do
        unconfirmed = build(:user, :unconfirmed, first_name: "Pending")
        unconfirmed.skip_confirmation_notification!
        unconfirmed.save!
      end

      total, = run(described_class)
      unconfirmed_count, = run(described_class, confirmed: false)
      confirmed_count, = run(described_class, confirmed: true)

      expect(total[:total]).to eq(2)
      expect(unconfirmed_count[:total]).to eq(1)
      expect(confirmed_count[:total]).to eq(1)
    end
  end

  describe Api::V1::Assistant::Tools::UsersWithoutPayroll do
    it "returns employees with no payroll entry in the range" do
      ActsAsTenant.with_tenant(organization) do
        paid = create(:user, first_name: "Paid")
        create(:user, first_name: "Unpaid")
        PayrollEntry.create!(user: paid, period_start: Date.current, period_end: Date.current, salary_type: "daily", net_amount: 1)
      end

      result, = run(described_class, from: Date.current.to_s, to: Date.current.to_s)

      expect(result.map { |row| row[:name] }).to include(a_string_starting_with("Unpaid"))
      expect(result.map { |row| row[:name] }).not_to include(a_string_starting_with("Paid"))
    end
  end

  describe Api::V1::Assistant::Tools::MoveTask do
    let!(:task) do
      ActsAsTenant.with_tenant(organization) do
        project = Project.create!(name: "Onboarding")
        Task.create!(project: project, title: "Draft plan", status: "todo")
      end
    end

    it "moves a task by title and records a reference" do
      result, references = run(described_class, task: "Draft plan", status: "done")

      expect(result[:status]).to eq("done")
      expect(task.reload.status).to eq("done")
      expect(references.first["type"]).to eq("task")
      expect(references.first["label"]).to eq("Draft plan")
    end

    it "rejects an invalid status" do
      result, = run(described_class, task: "Draft plan", status: "finished")

      expect(result[:error]).to include("Invalid status")
    end
  end
end
