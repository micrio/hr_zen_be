# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Leave management", type: :request do
  let(:organization) { create(:organization) }

  before { AuthMatrix::Initializer.setup_workspace!(organization) }

  let(:superadmin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("superadmin") }
    end
  end
  let(:employee) { create(:user, organization: organization) }
  let(:headers) { auth_headers(superadmin) }

  let(:leave_type) do
    ActsAsTenant.with_tenant(organization) do
      LeaveType.create!(name: "Vacation", default_days: 15)
    end
  end

  describe "leave types" do
    it "creates and lists leave types" do
      superadmin

      post "/api/v1/leave_types",
           params: { leave_type: { name: "Sick", default_days: 8 } },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:created)
      expect(response_body.dig("data", "name")).to eq("Sick")

      get "/api/v1/leave_types", headers: headers, as: :json

      expect(response_body["data"].map { |t| t["name"] }).to include("Sick")
    end

    it "forbids non-superadmins" do
      get "/api/v1/leave_types", headers: auth_headers(employee), as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/leave_balances/populate" do
    it "creates a balance per user with the default entitlement" do
      superadmin
      employee

      expect do
        post "/api/v1/leave_balances/populate",
             params: { leave_type_id: leave_type.id },
             headers: headers,
             as: :json
      end.to change(LeaveBalance, :count).by(2)

      expect(response).to have_http_status(:created)
      expect(response_body.dig("data", "created")).to eq(2)
    end

    it "is idempotent" do
      superadmin
      employee

      post "/api/v1/leave_balances/populate",
           params: { leave_type_id: leave_type.id }, headers: headers, as: :json

      expect do
        post "/api/v1/leave_balances/populate",
             params: { leave_type_id: leave_type.id }, headers: headers, as: :json
      end.not_to change(LeaveBalance, :count)
    end
  end

  describe "leave applications" do
    before do
      superadmin
      employee
      ActsAsTenant.with_tenant(organization) do
        LeaveBalance.create!(user: employee, leave_type: leave_type, entitled_days: 15)
      end
    end

    def create_application(days:, status: "approved")
      post "/api/v1/leave_applications",
           params: {
             leave_application: {
               user_id: employee.id,
               leave_type_id: leave_type.id,
               start_date: Date.current,
               end_date: Date.current + days.to_i - 1,
               days: days,
               status: status,
               reason: "rest"
             }
           },
           headers: headers,
           as: :json
    end

    it "deducts the balance for an approved application" do
      create_application(days: 3)

      expect(response).to have_http_status(:created)

      balance = ActsAsTenant.with_tenant(organization) do
        LeaveBalance.find_by!(user: employee, leave_type: leave_type)
      end

      expect(balance.used_days.to_f).to eq(3.0)
      expect(balance.remaining_days.to_f).to eq(12.0)
    end

    it "rejects an application that exceeds the remaining balance" do
      create_application(days: 20)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["error"]).to eq("Insufficient leave balance")
    end

    it "refunds the balance when the application is deleted" do
      create_application(days: 3)
      application = ActsAsTenant.with_tenant(organization) { LeaveApplication.last }

      expect do
        delete "/api/v1/leave_applications/#{application.id}", headers: headers, as: :json
      end.to change(LeaveApplication, :count).by(-1)

      balance = ActsAsTenant.with_tenant(organization) do
        LeaveBalance.find_by!(user: employee, leave_type: leave_type)
      end

      expect(balance.used_days.to_f).to eq(0.0)
    end

    it "refunds when an approved application is cancelled" do
      create_application(days: 4)
      application = ActsAsTenant.with_tenant(organization) { LeaveApplication.last }

      patch "/api/v1/leave_applications/#{application.id}",
            params: { leave_application: { status: "cancelled" } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)

      balance = ActsAsTenant.with_tenant(organization) do
        LeaveBalance.find_by!(user: employee, leave_type: leave_type)
      end

      expect(balance.used_days.to_f).to eq(0.0)
    end

    it "does not deduct a pending application" do
      create_application(days: 5, status: "pending")

      balance = ActsAsTenant.with_tenant(organization) do
        LeaveBalance.find_by!(user: employee, leave_type: leave_type)
      end

      expect(balance.used_days.to_f).to eq(0.0)
    end
  end
end
