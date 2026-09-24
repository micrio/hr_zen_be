# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Face registration", type: :request do
  let(:organization) { create(:organization) }

  before { AuthMatrix::Initializer.setup_workspace!(organization) }

  let(:superadmin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("superadmin") }
    end
  end
  let(:member) { create(:user, organization: organization) }
  let(:embedding) { Array.new(128) { 0.1 } }

  describe "POST /api/v1/users/:user_id/face" do
    it "lets a superadmin register a face for an employee" do
      post "/api/v1/users/#{member.id}/face",
           params: { face: { embedding: embedding } },
           headers: auth_headers(superadmin),
           as: :json

      expect(response).to have_http_status(:created)
      expect(response_body.dig("data", "registered")).to be true
      expect(response_body.dig("data", "count")).to eq(1)
    end

    it "lets a user register their own face" do
      post "/api/v1/users/#{member.id}/face",
           params: { face: { embedding: embedding } },
           headers: auth_headers(member),
           as: :json

      expect(response).to have_http_status(:created)
    end

    it "forbids registering a face for someone else" do
      post "/api/v1/users/#{superadmin.id}/face",
           params: { face: { embedding: embedding } },
           headers: auth_headers(member),
           as: :json

      expect(response).to have_http_status(:forbidden)
    end

    it "rejects an invalid embedding" do
      post "/api/v1/users/#{member.id}/face",
           params: { face: { embedding: [ 0.1, 0.2 ] } },
           headers: auth_headers(superadmin),
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["details"]).to have_key("vector")
    end

    it "requires authentication" do
      post "/api/v1/users/#{member.id}/face",
           params: { face: { embedding: embedding } },
           as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/users/:user_id/face" do
    it "reports registration status" do
      ActsAsTenant.with_tenant(organization) do
        member.face_embeddings.create!(vector: embedding)
      end

      get "/api/v1/users/#{member.id}/face", headers: auth_headers(superadmin), as: :json

      expect(response).to have_http_status(:ok)
      expect(response_body.dig("data", "registered")).to be true
    end
  end

  describe "DELETE /api/v1/users/:user_id/face" do
    it "removes all embeddings" do
      ActsAsTenant.with_tenant(organization) do
        member.face_embeddings.create!(vector: embedding)
      end

      expect do
        delete "/api/v1/users/#{member.id}/face", headers: auth_headers(superadmin), as: :json
      end.to change(FaceEmbedding, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end
  end
end
