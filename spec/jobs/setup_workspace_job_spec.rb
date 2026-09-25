# frozen_string_literal: true

require "rails_helper"

RSpec.describe SetupWorkspaceJob, type: :job do
  let(:organization) { create(:organization) }
  let(:owner) { create(:user, organization: organization) }

  before { organization.update!(owner: owner) }

  describe "#perform" do
    it "delegates to the AuthMatrix initializer with the organization" do
      allow(AuthMatrix::Initializer).to receive(:setup_workspace!)

      described_class.perform_now(organization.id)

      expect(AuthMatrix::Initializer).to have_received(:setup_workspace!).with(organization)
    end

    it "provisions the default roles and record types" do
      described_class.perform_now(organization.id)

      ActsAsTenant.with_tenant(organization) do
        expect(Role.pluck(:name)).to match_array(
          %w[admin hr_manager leave_approver employee]
        )
        expect(RecordType.pluck(:name)).to match_array(
          %w[User EmployeeProfile LeaveApplication SalarySlip]
        )
      end
    end

    it "assigns the admin role to the organization owner" do
      described_class.perform_now(organization.id)

      ActsAsTenant.with_tenant(organization) do
        expect(owner.reload.has_role?("admin")).to be true
      end
    end

    it "is idempotent" do
      described_class.perform_now(organization.id)

      expect { described_class.perform_now(organization.id) }
        .not_to change { ActsAsTenant.with_tenant(organization) { Role.count } }
    end
  end
end
