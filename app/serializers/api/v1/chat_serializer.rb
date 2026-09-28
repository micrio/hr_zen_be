# frozen_string_literal: true

module Api
  module V1
    class ChatSerializer < ActiveModel::Serializer
      attributes :id, :title, :messages_count, :created_at, :updated_at

      attribute :last_message

      def messages_count
        object.chat_messages.size
      end

      def last_message
        object.chat_messages.max_by(&:created_at)&.content&.first(80)
      end
    end
  end
end
