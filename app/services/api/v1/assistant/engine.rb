# frozen_string_literal: true

module Api
  module V1
    module Assistant
      # Thin wrapper around RubyLLM: builds the chat, registers the tools and
      # returns the reply plus the entity references the tools collected.
      class Engine
        PROVIDER = :deepseek
        DEFAULT_MODEL = "deepseek-chat"
        HISTORY_LIMIT = 20

        TOOLS = [
          Tools::FindUsers,
          Tools::CountUsers,
          Tools::UsersWithoutPayroll,
          Tools::ListTasks,
          Tools::MoveTask
        ].freeze

        def initialize(organization:, user:)
          @organization = organization
          @user = user
        end

        def respond(history:, content:)
          ensure_configured!

          reply_content = nil

          references = Context.with(organization: organization, user: user) do
            References.collect do
              chat = build_chat
              chat.with_instructions(system_prompt)

              history.last(HISTORY_LIMIT).each do |message|
                next unless %w[user assistant].include?(message.role)

                chat.add_message(role: message.role.to_sym, content: message.content)
              end

              response = chat.with_tools(*TOOLS).ask(content)
              reply_content = response.content.to_s
            end
          end

          { content: reply_content.to_s, references: references }
        end

        def self.provider
          PROVIDER
        end

        def self.model
          ENV.fetch("ASSISTANT_MODEL", DEFAULT_MODEL)
        end

        private

        attr_reader :organization, :user

        def build_chat
          options = { model: self.class.model, provider: self.class.provider.to_sym }

          # Allow provider-specific model names that aren't in RubyLLM's registry
          # (e.g. DeepSeek's `deepseek-chat`).
          options[:assume_model_exists] = true

          RubyLLM.chat(**options)
        end

        def ensure_configured!
          return if ENV["DEEPSEEK_API_KEY"].present?

          raise Api::Error::UnprocessableEntity.new(
            "Assistant is not configured",
            details: { base: [ "Set DEEPSEEK_API_KEY in the backend .env." ] }
          )
        end

        def system_prompt
          <<~PROMPT
            You are the HR Zen assistant for the organization "#{organization.name}".
            You help HR admins with employees, attendance, leaves, payroll and tasks.
            Use the provided tools to look data up or change it; never invent records.
            When you change something, say exactly what you changed.
            Keep answers short; use markdown lists when listing records.
          PROMPT
        end
      end
    end
  end
end
