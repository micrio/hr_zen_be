# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Activities (paper trail)", type: :request do
  let(:organization) { create(:organization) }

  before { AuthMatrix::Initializer.setup_workspace!(organization) }

  let(:admin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
    end
  end
  let(:member) { create(:user, organization: organization) }
  let(:headers) { auth_headers(admin) }

  it "records an activity attributed to the acting user" do
    admin

    post "/api/v1/users",
         params: {
           user: {
             email: "trail@example.com",
             first_name: "Trail",
             last_name: "Blazer",
             password: "password123",
             password_confirmation: "password123"
           }
         },
         headers: headers,
         as: :json

    expect(response).to have_http_status(:created)

    version = PaperTrail::Version.where(item_type: "User", event: "create").last
    expect(version.organization_id).to eq(organization.id)
    expect(version.whodunnit).to eq(admin.id.to_s)
  end

  it "lists activities scoped to the organization" do
    admin

    patch "/api/v1/users/#{member.id}",
          params: { user: { first_name: "Renamed" } },
          headers: headers,
          as: :json

    get "/api/v1/activities?item_type=User", headers: headers, as: :json

    expect(response).to have_http_status(:ok)
    expect(response_body["data"]).not_to be_empty
    row = response_body["data"].find { |item| item["item_id"] == member.id }
    expect(row["event"]).to eq("update")
    expect(row["actor_name"]).to eq(admin.full_name)
    expect(row["changes"]).to have_key("first_name")
  end

  it "filters by actor" do
    admin

    patch "/api/v1/users/#{member.id}",
          params: { user: { first_name: "ActorTest" } },
          headers: headers,
          as: :json

    get "/api/v1/activities?user_id=#{admin.id}", headers: headers, as: :json

    expect(response).to have_http_status(:ok)
    expect(response_body["data"].map { |row| row["actor_id"] }.uniq).to eq([ admin.id ])
  end

  it "forbids non-admins" do
    get "/api/v1/activities", headers: auth_headers(member), as: :json

    expect(response).to have_http_status(:forbidden)
  end
end
