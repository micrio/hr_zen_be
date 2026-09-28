# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assistant chats", type: :request do
  def admin_for(plan)
    organization = create(:organization, plan: plan)
    AuthMatrix::Initializer.setup_workspace!(organization)
    admin = create(:user, organization: organization).tap do |user|
      ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
    end
    [ organization, admin ]
  end

  describe "with the assistant feature" do
    let(:organization) { create(:organization, plan: "pro") }
    let(:admin) do
      create(:user, organization: organization).tap do |user|
        ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
      end
    end
    let(:headers) { auth_headers(admin) }

    before { AuthMatrix::Initializer.setup_workspace!(organization) }

    it "creates, lists, shows and deletes a chat" do
      post "/api/v1/chats", headers: headers, as: :json
      expect(response).to have_http_status(:created)
      chat_id = response_body.dig("data", "id")

      get "/api/v1/chats", headers: headers, as: :json
      expect(response_body["data"].map { |c| c["id"] }).to include(chat_id)

      get "/api/v1/chats/#{chat_id}", headers: headers, as: :json
      expect(response_body.dig("data", "chat", "id")).to eq(chat_id)
      expect(response_body.dig("data", "messages")).to eq([])

      expect do
        delete "/api/v1/chats/#{chat_id}", headers: headers, as: :json
      end.to change(Chat, :count).by(-1)
    end

    it "shows a plain-text preview (markdown stripped) in the list" do
      chat = ActsAsTenant.with_tenant(organization) { admin.chats.create!(title: "Preview") }
      ActsAsTenant.with_tenant(organization) do
        chat.chat_messages.create!(
          role: "assistant",
          content: "Here are 3 employees:\n\n- **Jake Ryan** — jake@su.edu\n- **Jasper** — jasper@user.com"
        )
      end

      get "/api/v1/chats", headers: headers, as: :json

      preview = response_body["data"].find { |row| row["id"] == chat.id }["last_message"]
      expect(preview).to include("Jake Ryan")
      expect(preview).not_to include("**")
      expect(preview).not_to include("\n")
    end

    it "scopes chats to the current user" do
      other = ActsAsTenant.with_tenant(organization) { create(:user) }
      other_chat = ActsAsTenant.with_tenant(organization) { other.chats.create! }

      get "/api/v1/chats/#{other_chat.id}", headers: headers, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "without the assistant feature" do
    let(:organization) { create(:organization, plan: "free") }
    let(:admin) do
      create(:user, organization: organization).tap do |user|
        ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
      end
    end

    before { AuthMatrix::Initializer.setup_workspace!(organization) }

    it "is forbidden" do
      get "/api/v1/chats", headers: auth_headers(admin), as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end
end
