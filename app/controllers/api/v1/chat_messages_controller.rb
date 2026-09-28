# frozen_string_literal: true

module Api
  module V1
    class ChatMessagesController < BaseController
      plan_feature :assistant

      # POST /api/v1/chats/:chat_id/messages
      def create
        chat = current_user.chats.find(params[:chat_id])

        result = Api::V1::Assistant::ChatService.new(
          chat: chat,
          content: params[:content]
        ).perform

        render_jsonapi(
          {
            message: Api::V1::ChatMessageSerializer.new(result[:message]).serializable_hash,
            reply: Api::V1::ChatMessageSerializer.new(result[:reply]).serializable_hash
          },
          status: :created,
          meta: { message: "Message sent." }
        )
      end
    end
  end
end
