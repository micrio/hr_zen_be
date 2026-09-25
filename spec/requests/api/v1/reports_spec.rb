# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /api/v1/reports/summary", type: :request do
  def admin_for(plan)
    organization = create(:organization, plan: plan)
    AuthMatrix::Initializer.setup_workspace!(organization)
    admin = create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
    end
    [ organization, admin ]
  end

  context "pro plan" do
    let(:organization) { create(:organization, plan: "pro") }
    let(:admin) do
      create(:user, organization: organization).tap do |user|
        ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
      end
    end

    before { AuthMatrix::Initializer.setup_workspace!(organization) }

    it "returns an aggregated summary" do
      ActsAsTenant.with_tenant(organization) do
        AttendanceEvent.create!(user: admin, kind: "clock_in", occurred_at: Time.current)
        leave_type = LeaveType.create!(name: "Vacation", default_days: 10)
        LeaveApplication.create!(
          user: admin, leave_type: leave_type, start_date: Date.current,
          end_date: Date.current, days: 2, status: "approved"
        )
      end

      get "/api/v1/reports/summary", headers: auth_headers(admin), as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body.dig("data", "headcount")).to eq(1)
      expect(response_body.dig("data", "attendance", "clock_ins")).to eq(1)
      expect(response_body.dig("data", "leaves", "days_used")).to eq(2.0)
      expect(response_body.dig("data", "payroll")).to include("net_total")
    end
  end

  context "report rows" do
    let(:organization) { create(:organization, plan: "enterprise") }
    let(:admin) do
      create(:user, organization: organization).tap do |user|
        ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
      end
    end

    before { AuthMatrix::Initializer.setup_workspace!(organization) }

    %w[attendance leaves payroll headcount].each do |kind|
      it "returns #{kind} columns and rows" do
        get "/api/v1/reports/#{kind}", headers: auth_headers(admin), as: :json

        expect(response).to have_http_status(:ok)
        expect(response_body.dig("data", "report")).to eq(kind)
        expect(response_body.dig("data", "columns")).to be_an(Array)
        expect(response_body.dig("data", "rows")).to be_an(Array)
      end
    end

    it "404s for an unknown report" do
      get "/api/v1/reports/nope", headers: auth_headers(admin), as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  context "free plan" do
    let(:organization) { create(:organization, plan: "free") }
    let(:admin) do
      create(:user, organization: organization).tap do |user|
        ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
      end
    end

    before { AuthMatrix::Initializer.setup_workspace!(organization) }

    it "is blocked" do
      get "/api/v1/reports/summary", headers: auth_headers(admin), as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end
end
