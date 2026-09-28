# frozen_string_literal: true

module Api
  module V1
    class ChatsController < BaseController
      plan_feature :assistant

      # GET /api/v1/chats
      def index
        chats = current_user.chats.includes(:chat_messages).recent_first

        render_jsonapi(
          chats.map { |chat| Api::V1::ChatSerializer.new(chat).serializable_hash }
        )
      end

      # GET /api/v1/chats/:id
      def show
        chat = current_user.chats.find(params[:id])

        render_jsonapi(
          {
            chat: Api::V1::ChatSerializer.new(chat).serializable_hash,
            messages: chat.chat_messages.chronological.map do |message|
              Api::V1::ChatMessageSerializer.new(message).serializable_hash
            end
          }
        )
      end

      # POST /api/v1/chats
      def create
        chat = current_user.chats.create!

        render_jsonapi(
          Api::V1::ChatSerializer.new(chat).serializable_hash,
          status: :created,
          meta: { message: "Chat created." }
        )
      end

      # DELETE /api/v1/chats/:id
      def destroy
        current_user.chats.find(params[:id]).destroy!

        render_jsonapi({}, meta: { message: "Chat deleted." })
      end
    end
  end
end
