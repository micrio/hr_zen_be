# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Payroll", type: :request do
  let(:organization) { create(:organization) }

  before { AuthMatrix::Initializer.setup_workspace!(organization) }

  let(:superadmin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("superadmin") }
    end
  end
  let(:employee) { create(:user, organization: organization) }
  let(:headers) { auth_headers(superadmin) }

  describe "payroll settings" do
    it "returns defaults and updates them" do
      superadmin

      get "/api/v1/payroll/setting", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body.dig("data", "currency")).to eq("USD")

      patch "/api/v1/payroll/setting",
            params: { payroll_setting: { currency: "PHP", default_salary_type: "monthly" } },
            headers: headers,
            as: :json

      expect(response_body.dig("data", "currency")).to eq("PHP")
      expect(response_body.dig("data", "default_salary_type")).to eq("monthly")
    end

    it "forbids non-superadmins" do
      get "/api/v1/payroll/setting", headers: auth_headers(employee), as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "compensations" do
    it "creates and updates an employee compensation" do
      superadmin

      post "/api/v1/compensations",
           params: { compensation: { user_id: employee.id, salary_type: "daily", rate: 500 } },
           headers: headers,
           as: :json

      expect(response).to have_http_status(:created)
      expect(response_body.dig("data", "rate")).to eq(500.0)

      id = response_body.dig("data", "id")

      patch "/api/v1/compensations/#{id}",
            params: { compensation: { salary_type: "hourly", rate: 100 } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body.dig("data", "salary_type")).to eq("hourly")
    end
  end

  describe "POST /api/v1/payroll_entries" do
    before do
      superadmin
      ActsAsTenant.with_tenant(organization) do
        Compensation.create!(user: employee, salary_type: salary_type, rate: rate)
      end
    end

    let(:salary_type) { "hourly" }
    let(:rate) { 100 }

    def calculate(units: nil, adjustments: [], **overrides)
      payload = {
        user_id: employee.id,
        period_start: "2026-10-01",
        period_end: "2026-10-31",
        units: units,
        adjustments: adjustments
      }.merge(overrides)

      post "/api/v1/payroll_entries",
           params: { payroll_entry: payload },
           headers: headers,
           as: :json
    end

    context "when hourly" do
      it "multiplies rate by hours and applies adjustments" do
        calculate(units: 8, adjustments: [
          { label: "Bonus", kind: "earning", amount: 200 },
          { label: "Tax", kind: "deduction", amount: 50 }
        ])

        expect(response).to have_http_status(:created)
        expect(response_body.dig("data", "gross_amount")).to eq(800.0)
        expect(response_body.dig("data", "net_amount")).to eq(950.0)
      end
    end

    context "when daily" do
      let(:salary_type) { "daily" }
      let(:rate) { 500 }

      it "multiplies rate by days" do
        calculate(units: 10)

        expect(response_body.dig("data", "gross_amount")).to eq(5000.0)
      end

      it "derives days from attendance when units are omitted" do
        ActsAsTenant.with_tenant(organization) do
          AttendanceEvent.create!(user: employee, kind: "clock_in", occurred_at: Time.zone.parse("2026-10-02 09:00"))
          AttendanceEvent.create!(user: employee, kind: "clock_out", occurred_at: Time.zone.parse("2026-10-02 18:00"))
          AttendanceEvent.create!(user: employee, kind: "clock_in", occurred_at: Time.zone.parse("2026-10-03 09:00"))
        end

        calculate

        expect(response_body.dig("data", "units")).to eq(2.0)
        expect(response_body.dig("data", "gross_amount")).to eq(1000.0)
      end
    end

    context "when monthly" do
      let(:salary_type) { "monthly" }
      let(:rate) { 30000 }

      it "uses the fixed rate" do
        calculate

        expect(response_body.dig("data", "gross_amount")).to eq(30000.0)
      end
    end

    context "without a compensation" do
      it "returns 422" do
        ActsAsTenant.with_tenant(organization) { Compensation.delete_all }

        calculate(units: 8)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body["error"]).to eq("No compensation set for this employee")
      end
    end
  end
end
