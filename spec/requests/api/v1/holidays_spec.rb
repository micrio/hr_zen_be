# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Holidays", type: :request do
  let(:organization) { create(:organization) }

  before { AuthMatrix::Initializer.setup_workspace!(organization) }

  let(:admin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
    end
  end
  let(:member) { create(:user, organization: organization) }
  let(:headers) { auth_headers(admin) }

  it "creates and lists holidays" do
    admin

    post "/api/v1/holidays",
         params: { holiday: { name: "New Year", date: "2026-01-01", recurring: true } },
         headers: headers,
         as: :json

    expect(response).to have_http_status(:created)
    expect(response_body.dig("data", "name")).to eq("New Year")

    get "/api/v1/holidays?year=2026", headers: headers, as: :json

    expect(response).to have_http_status(:ok)
    expect(response_body["data"].map { |h| h["name"] }).to include("New Year")
  end

  it "rejects a duplicate date" do
    admin
    ActsAsTenant.with_tenant(organization) do
      Holiday.create!(name: "Christmas", date: "2026-12-25")
    end

    post "/api/v1/holidays",
         params: { holiday: { name: "Xmas", date: "2026-12-25" } },
         headers: headers,
         as: :json

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response_body["details"]).to have_key("date")
  end

  it "updates and deletes a holiday" do
    admin
    holiday = ActsAsTenant.with_tenant(organization) do
      Holiday.create!(name: "Old", date: "2026-05-01")
    end

    patch "/api/v1/holidays/#{holiday.id}",
          params: { holiday: { name: "Labor Day" } },
          headers: headers,
          as: :json

    expect(response).to have_http_status(:ok)
    expect(response_body.dig("data", "name")).to eq("Labor Day")

    expect do
      delete "/api/v1/holidays/#{holiday.id}", headers: headers, as: :json
    end.to change(Holiday, :count).by(-1)
  end

  it "filters by year, keeping recurring holidays" do
    admin
    ActsAsTenant.with_tenant(organization) do
      Holiday.create!(name: "2025 only", date: "2025-06-01")
      Holiday.create!(name: "Recurring", date: "2024-01-01", recurring: true)
      Holiday.create!(name: "2026 day", date: "2026-03-01")
    end

    get "/api/v1/holidays?year=2026", headers: headers, as: :json

    names = response_body["data"].map { |h| h["name"] }
    expect(names).to match_array([ "Recurring", "2026 day" ])
  end

  it "forbids non-admins" do
    get "/api/v1/holidays", headers: auth_headers(member), as: :json

    expect(response).to have_http_status(:forbidden)
  end
end
