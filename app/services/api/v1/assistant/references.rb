# frozen_string_literal: true

module Api
  module V1
    module Assistant
      # Collects entity links produced by tool calls so the client can render
      # clickable chips next to the assistant's reply.
      module References
        KEY = :hr_zen_assistant_references

        module_function

        def collect
          previous = Thread.current[KEY]
          Thread.current[KEY] = []
          yield
          Thread.current[KEY] || []
        ensure
          Thread.current[KEY] = previous
        end

        def add(type:, id:, label:, href:)
          list = (Thread.current[KEY] ||= [])
          reference = {
            "type" => type.to_s,
            "id" => id,
            "label" => label.to_s,
            "href" => href
          }
          list << reference unless list.include?(reference)
        end

        def reference(type:, id:, label:, href:)
          { "type" => type.to_s, "id" => id, "label" => label.to_s, "href" => href }
        end
      end
    end
  end
end
