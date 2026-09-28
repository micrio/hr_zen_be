# frozen_string_literal: true

module Api
  module V1
    module Assistant
      # Turns a markdown reply into a plain one-line preview for chat lists.
      module Preview
        DEFAULT_LIMIT = 80

        module_function

        def plain(text, limit: DEFAULT_LIMIT)
          return nil if text.blank?

          value = text.to_s
          value = value.gsub(/```.*?```/m, " ")                # fenced code
          value = value.gsub(/`([^`]*)`/, '\1')                # inline code
          value = value.gsub(/!\[([^\]]*)\]\([^)]*\)/, '\1')   # images
          value = value.gsub(/\[([^\]]*)\]\([^)]*\)/, '\1')    # links
          value = value.gsub(/^\s{0,3}(?:[#>\-*+]|\d+\.)\s+/, "") # headings/quotes/bullets
          value = value.gsub(/[*_~]/, "")                      # emphasis markers
          value = value.gsub(/\s+/, " ").strip

          value.truncate(limit)
        end
      end
    end
  end
end
