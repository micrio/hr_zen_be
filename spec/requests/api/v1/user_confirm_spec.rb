# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /api/v1/users/:id/confirm", type: :request do
  let(:organization) { create(:organization) }

  before { AuthMatrix::Initializer.setup_workspace!(organization) }

  let(:superadmin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("superadmin") }
    end
  end
  let(:member) { create(:user, organization: organization) }
  let(:headers) { auth_headers(superadmin) }

  def unconfirmed_user
    build(:user, :unconfirmed, organization: organization).tap do |user|
      user.skip_confirmation_notification!
      user.save!
    end
  end

  it "force-confirms an unconfirmed user" do
    superadmin
    target = unconfirmed_user
    expect(target.confirmed?).to be false

    post "/api/v1/users/#{target.id}/confirm", headers: headers, as: :json

    expect(response).to have_http_status(:ok)
    expect(response_body.dig("data", "confirmed_at")).to be_present
    expect(target.reload.confirmed?).to be true
    expect(target.confirmation_token).to be_nil
  end

  it "is idempotent for an already confirmed user" do
    superadmin
    target = create(:user, organization: organization)

    post "/api/v1/users/#{target.id}/confirm", headers: headers, as: :json

    expect(response).to have_http_status(:ok)
    expect(target.reload.confirmed?).to be true
  end

  it "forbids non-superadmins" do
    target = unconfirmed_user

    post "/api/v1/users/#{target.id}/confirm",
         headers: auth_headers(member),
         as: :json

    expect(response).to have_http_status(:forbidden)
    expect(target.reload.confirmed?).to be false
  end

  it "requires authentication" do
    target = unconfirmed_user

    post "/api/v1/users/#{target.id}/confirm", as: :json

    expect(response).to have_http_status(:unauthorized)
  end
end
