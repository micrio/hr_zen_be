# frozen_string_literal: true

module Api
  module V1
    module Assistant
      # Persists the user message, asks the model, persists the reply.
      class ChatService
        HISTORY_LIMIT = 20

        def initialize(args)
          @chat = args[:chat]
          @content = args[:content].to_s.strip
        end

        def perform
          if content.blank?
            raise Api::Error::UnprocessableEntity.new(
              "Message is required", details: { content: [ "is required" ] }
            )
          end

          user_message = chat.chat_messages.create!(role: "user", content: content)
          history = chat.chat_messages.chronological.where.not(id: user_message.id).last(HISTORY_LIMIT)

          reply = engine.respond(history: history, content: content)

          assistant_message = chat.chat_messages.create!(
            role: "assistant",
            content: reply[:content].presence || "I couldn't produce an answer.",
            metadata: { "references" => reply[:references] || [] }
          )

          chat.touch_activity(title_from: content)

          { message: user_message, reply: assistant_message }
        end

        private

        attr_reader :chat, :content

        def engine
          @engine ||= Engine.new(organization: chat.organization, user: chat.user)
        end
      end
    end
  end
end
