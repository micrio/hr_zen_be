# frozen_string_literal: true

module Api
  module V1
    module Assistant
      # Per-request tenant/user context for tools (tools are instantiated by
      # RubyLLM without arguments, so we hand them context via the thread).
      module Context
        KEY = :hr_zen_assistant_context

        module_function

        def with(organization:, user:)
          previous = Thread.current[KEY]
          Thread.current[KEY] = { organization: organization, user: user }
          yield
        ensure
          Thread.current[KEY] = previous
        end

        def current
          Thread.current[KEY] || {}
        end

        def organization
          current[:organization]
        end

        def user
          current[:user]
        end
      end
    end
  end
end
