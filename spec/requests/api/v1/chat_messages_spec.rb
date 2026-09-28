# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /api/v1/chats/:chat_id/messages", type: :request do
  let(:organization) { create(:organization, plan: "pro") }
  let(:admin) do
    user = create(:user, organization: organization)
    AuthMatrix::Initializer.setup_workspace!(organization)
    ActsAsTenant.with_tenant(organization) { user.assign_role("admin") }
    user
  end
  let!(:chat) { ActsAsTenant.with_tenant(organization) { admin.chats.create! } }
  let(:headers) { auth_headers(admin) }

  it "stores the user message and the assistant reply with references" do
    reference = { "type" => "user", "id" => 1, "label" => "Jane Doe", "href" => "/users" }

    allow_any_instance_of(Api::V1::Assistant::Engine).to receive(:respond)
      .and_return({ content: "Here are 5 recent unconfirmed employees.", references: [ reference ] })

    expect do
      post "/api/v1/chats/#{chat.id}/messages",
           params: { content: "pull up 5 recent employees not yet confirmed" },
           headers: headers,
           as: :json
    end.to change(ChatMessage, :count).by(2)

    expect(response).to have_http_status(:created)
    expect(response_body.dig("data", "message", "role")).to eq("user")
    expect(response_body.dig("data", "reply", "role")).to eq("assistant")
    expect(response_body.dig("data", "reply", "content")).to eq("Here are 5 recent unconfirmed employees.")
    expect(response_body.dig("data", "reply", "metadata", "references")).to eq([ reference ])
  end

  it "titles a new chat from the first message" do
    allow_any_instance_of(Api::V1::Assistant::Engine).to receive(:respond)
      .and_return({ content: "ok", references: [] })

    post "/api/v1/chats/#{chat.id}/messages",
         params: { content: "show me users without payroll this month" },
         headers: headers,
         as: :json

    expect(chat.reload.title).to eq("show me users without payroll this month")
  end

  it "rejects a blank message" do
    post "/api/v1/chats/#{chat.id}/messages",
         params: { content: "  " }, headers: headers, as: :json

    expect(response).to have_http_status(:unprocessable_entity)
  end
end
