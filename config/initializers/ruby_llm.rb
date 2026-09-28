# frozen_string_literal: true

# The assistant uses DeepSeek. Only the API key is required.
RubyLLM.configure do |config|
  config.deepseek_api_key = ENV["DEEPSEEK_API_KEY"] if ENV["DEEPSEEK_API_KEY"].present?
end
