# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Kiosk", type: :request do
  let(:organization) { create(:organization) }

  before { AuthMatrix::Initializer.setup_workspace!(organization) }

  let(:employee) { create(:user, organization: organization) }
  let(:embedding) { Array.new(128) { 0.1 } }

  let!(:setting) do
    ActsAsTenant.with_tenant(organization) do
      AttendanceSetting.create!(
        organization: organization,
        enabled: true,
        cooldown_seconds: 0
      )
    end
  end

  before do
    ActsAsTenant.with_tenant(organization) do
      employee.face_embeddings.create!(vector: embedding)
    end
  end

  describe "GET /api/v1/kiosk/:token" do
    it "returns the organization info without authentication" do
      get "/api/v1/kiosk/#{setting.clock_token}", as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body.dig("data", "organization", "name")).to eq(organization.name)
      expect(response_body.dig("data", "cooldown_seconds")).to eq(0)
    end

    it "404s when attendance is disabled" do
      setting.update!(enabled: false)

      get "/api/v1/kiosk/#{setting.clock_token}", as: :json

      expect(response).to have_http_status(:not_found)
    end

    it "404s for an unknown token" do
      get "/api/v1/kiosk/nope", as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/kiosk/:token/clock" do
    it "clocks a recognized employee in without authentication" do
      post "/api/v1/kiosk/#{setting.clock_token}/clock",
           params: { attendance: { embedding: embedding } },
           as: :json

      expect(response).to have_http_status(:created)
      expect(response_body.dig("data", "event", "kind")).to eq("clock_in")
      expect(response_body.dig("data", "user", "id")).to eq(employee.id)
    end

    it "404s when attendance is disabled" do
      setting.update!(enabled: false)

      post "/api/v1/kiosk/#{setting.clock_token}/clock",
           params: { attendance: { embedding: embedding } },
           as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
