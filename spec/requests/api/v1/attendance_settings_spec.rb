# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Attendance settings", type: :request do
  let(:organization) { create(:organization) }

  before { AuthMatrix::Initializer.setup_workspace!(organization) }

  let(:admin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
    end
  end
  let(:member) { create(:user, organization: organization) }
  let(:headers) { auth_headers(admin) }

  describe "GET /api/v1/attendance/setting" do
    it "creates and returns a setting with a unique clock token" do
      get "/api/v1/attendance/setting", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body.dig("data", "enabled")).to be false
      expect(response_body.dig("data", "clock_token")).to be_present
      expect(response_body.dig("data", "cooldown_seconds")).to eq(60)
    end

    it "forbids non-admins" do
      get "/api/v1/attendance/setting", headers: auth_headers(member), as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/v1/attendance/setting" do
    it "enables attendance and sets the cooldown" do
      patch "/api/v1/attendance/setting",
            params: { attendance_setting: { enabled: true, cooldown_seconds: 120 } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body.dig("data", "enabled")).to be true
      expect(response_body.dig("data", "cooldown_seconds")).to eq(120)
    end

    it "rejects an invalid cooldown" do
      patch "/api/v1/attendance/setting",
            params: { attendance_setting: { cooldown_seconds: -5 } },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["details"]).to have_key("cooldown_seconds")
    end
  end
end
