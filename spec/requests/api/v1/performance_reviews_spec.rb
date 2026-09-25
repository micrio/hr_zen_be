# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Performance reviews", type: :request do
  let(:organization) { create(:organization) }

  before { AuthMatrix::Initializer.setup_workspace!(organization) }

  let(:superadmin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("superadmin") }
    end
  end
  let(:employee) { create(:user, organization: organization) }
  let(:member) { create(:user, organization: organization) }
  let(:headers) { auth_headers(superadmin) }

  def params_for(overrides = {})
    {
      performance_review: {
        user_id: employee.id,
        period_start: "2026-01-01",
        period_end: "2026-06-30",
        review_date: "2026-07-01",
        rating: 4.5,
        status: "submitted",
        summary: "Solid half.",
        strengths: "Ownership",
        improvements: "Docs"
      }.merge(overrides)
    }
  end

  it "creates a review attributed to the current user" do
    superadmin

    expect do
      post "/api/v1/performance_reviews", params: params_for, headers: headers, as: :json
    end.to change(PerformanceReview, :count).by(1)

    expect(response).to have_http_status(:created)
    expect(response_body.dig("data", "rating")).to eq(4.5)
    expect(response_body.dig("data", "reviewer_id")).to eq(superadmin.id)
  end

  it "lists reviews for a user" do
    superadmin
    ActsAsTenant.with_tenant(organization) do
      PerformanceReview.create!(user: employee, status: "draft", rating: 3)
    end

    get "/api/v1/performance_reviews?user_id=#{employee.id}", headers: headers, as: :json

    expect(response).to have_http_status(:ok)
    expect(response_body["data"].length).to eq(1)
    expect(response_body["data"].first["user_name"]).to eq(employee.full_name)
  end

  it "filters by status" do
    superadmin
    ActsAsTenant.with_tenant(organization) do
      PerformanceReview.create!(user: employee, status: "draft")
      PerformanceReview.create!(user: employee, status: "acknowledged")
    end

    get "/api/v1/performance_reviews?status=acknowledged", headers: headers, as: :json

    expect(response_body["data"].length).to eq(1)
    expect(response_body["data"].first["status"]).to eq("acknowledged")
  end

  it "updates a review" do
    superadmin
    review = ActsAsTenant.with_tenant(organization) do
      PerformanceReview.create!(user: employee, status: "draft")
    end

    patch "/api/v1/performance_reviews/#{review.id}",
          params: { performance_review: { status: "acknowledged", rating: 5 } },
          headers: headers,
          as: :json

    expect(response).to have_http_status(:ok)
    expect(response_body.dig("data", "status")).to eq("acknowledged")
    expect(response_body.dig("data", "rating")).to eq(5.0)
  end

  it "rejects an inverted period" do
    superadmin

    post "/api/v1/performance_reviews",
         params: params_for(period_end: "2025-01-01"),
         headers: headers,
         as: :json

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response_body["details"]).to have_key("period_end")
  end

  it "deletes a review" do
    superadmin
    review = ActsAsTenant.with_tenant(organization) do
      PerformanceReview.create!(user: employee, status: "draft")
    end

    expect do
      delete "/api/v1/performance_reviews/#{review.id}", headers: headers, as: :json
    end.to change(PerformanceReview, :count).by(-1)
  end

  it "forbids non-superadmins" do
    get "/api/v1/performance_reviews", headers: auth_headers(member), as: :json

    expect(response).to have_http_status(:forbidden)
  end
end
