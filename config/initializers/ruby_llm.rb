# frozen_string_literal: true

# LLM provider credentials. DeepSeek is the default provider for the
# assistant; other providers are still picked up if their key is present.
RubyLLM.configure do |config|
  config.deepseek_api_key = ENV["DEEPSEEK_API_KEY"] if ENV["DEEPSEEK_API_KEY"].present?
  config.deepseek_api_base = ENV["DEEPSEEK_API_BASE"] if ENV["DEEPSEEK_API_BASE"].present?

  config.openai_api_key = ENV["OPENAI_API_KEY"] if ENV["OPENAI_API_KEY"].present?
  config.anthropic_api_key = ENV["ANTHROPIC_API_KEY"] if ENV["ANTHROPIC_API_KEY"].present?
  config.ollama_api_base = ENV["OLLAMA_API_BASE"] if ENV["OLLAMA_API_BASE"].present?
end
