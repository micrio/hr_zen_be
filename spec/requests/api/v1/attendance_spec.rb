# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Attendance", type: :request do
  let(:organization) { create(:organization) }

  before { AuthMatrix::Initializer.setup_workspace!(organization) }

  let(:superadmin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("superadmin") }
    end
  end
  let(:employee) { create(:user, organization: organization) }
  let(:embedding) { Array.new(128) { 0.1 } }

  before do
    ActsAsTenant.with_tenant(organization) do
      employee.face_embeddings.create!(vector: embedding)
      AttendanceSetting.create!(organization: organization, cooldown_seconds: 0)
    end
  end

  describe "POST /api/v1/attendance/clock" do
    it "clocks the recognized employee in, then out, on repeat scans" do
      post "/api/v1/attendance/clock",
           params: { attendance: { embedding: embedding } },
           headers: auth_headers(superadmin),
           as: :json

      expect(response).to have_http_status(:created)
      expect(response_body.dig("data", "event", "kind")).to eq("clock_in")
      expect(response_body.dig("data", "user", "id")).to eq(employee.id)
      expect(response_body.dig("meta", "next_action")).to eq("clock_out")

      post "/api/v1/attendance/clock",
           params: { attendance: { embedding: embedding } },
           headers: auth_headers(superadmin),
           as: :json

      expect(response_body.dig("data", "event", "kind")).to eq("clock_out")
      expect(response_body.dig("meta", "next_action")).to eq("clock_in")
    end

    it "skips a repeat scan inside the cooldown window" do
      ActsAsTenant.with_tenant(organization) do
        AttendanceSetting.find_by!(organization: organization).update!(cooldown_seconds: 3600)
      end

      post "/api/v1/attendance/clock",
           params: { attendance: { embedding: embedding } },
           headers: auth_headers(superadmin),
           as: :json

      expect(response).to have_http_status(:created)

      post "/api/v1/attendance/clock",
           params: { attendance: { embedding: embedding } },
           headers: auth_headers(superadmin),
           as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body.dig("meta", "skipped")).to be true
      expect(response_body.dig("meta", "cooldown_remaining")).to be > 0
    end

    it "rejects an unrecognized face" do
      post "/api/v1/attendance/clock",
           params: { attendance: { embedding: Array.new(128) { 2.5 } } },
           headers: auth_headers(superadmin),
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["error"]).to eq("Face not recognized")
    end

    it "requires authentication" do
      post "/api/v1/attendance/clock",
           params: { attendance: { embedding: embedding } },
           as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/attendance/events" do
    before do
      ActsAsTenant.with_tenant(organization) do
        AttendanceEvent.create!(user: employee, kind: "clock_in", occurred_at: Time.current)
      end
    end

    it "returns the current user's events" do
      get "/api/v1/attendance/events", headers: auth_headers(employee), as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body["data"].length).to eq(1)
      expect(response_body["data"].first["kind"]).to eq("clock_in")
    end

    it "lets a superadmin filter by user" do
      get "/api/v1/attendance/events?user_id=#{employee.id}",
          headers: auth_headers(superadmin),
          as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body["data"].first["user_id"]).to eq(employee.id)
    end
  end
end
