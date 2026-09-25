# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /api/v1/pdf_extractions", type: :request do
  let(:organization) { create(:organization) }

  before { AuthMatrix::Initializer.setup_workspace!(organization) }

  let(:admin) do
    create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
    end
  end
  let(:member) { create(:user, organization: organization) }
  let(:headers) { auth_headers(admin) }

  def upload(content_type: "application/pdf")
    file = Tempfile.new([ "profile", ".pdf" ])
    file.write("%PDF-1.4 fake")
    file.rewind
    Rack::Test::UploadedFile.new(file.path, content_type)
  end

  describe "with a readable PDF" do
    before do
      page = double(text: "First Name: Ada\nLast Name: Lovelace\nEmail: ada@example.com")
      reader = double(pages: [ page ], page_count: 1)
      allow(PDF::Reader).to receive(:new).and_return(reader)
    end

    it "returns parsed profile fields" do
      admin

      post "/api/v1/pdf_extractions", params: { file: upload }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(response_body.dig("data", "fields", "first_name")).to eq("Ada")
      expect(response_body.dig("data", "fields", "last_name")).to eq("Lovelace")
      expect(response_body.dig("data", "fields", "email")).to eq("ada@example.com")
    end
  end

  describe "with an unsupported file type" do
    it "returns 422" do
      admin

      post "/api/v1/pdf_extractions",
           params: { file: upload(content_type: "text/plain") },
           headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body["details"]).to have_key("file")
    end
  end

  describe "with a missing file" do
    it "returns 422" do
      admin

      post "/api/v1/pdf_extractions", params: {}, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "authorization" do
    it "forbids non-admins" do
      post "/api/v1/pdf_extractions", params: { file: upload }, headers: auth_headers(member)

      expect(response).to have_http_status(:forbidden)
    end

    it "requires authentication" do
      post "/api/v1/pdf_extractions", params: { file: upload }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
