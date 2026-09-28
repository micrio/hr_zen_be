# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Assistant::Engine do
  around do |example|
    keys = %w[DEEPSEEK_API_KEY]
    saved = keys.index_with { |key| ENV[key] }
    keys.each { |key| ENV.delete(key) }

    example.run
  ensure
    saved.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end

  it "defaults to the DeepSeek provider and model" do
    expect(described_class.provider).to eq(:deepseek)
    expect(described_class.model).to eq("deepseek-chat")
  end

  it "reads the model from ENV" do
    ENV["ASSISTANT_MODEL"] = "deepseek-reasoner"

    expect(described_class.model).to eq("deepseek-reasoner")
  ensure
    ENV.delete("ASSISTANT_MODEL")
  end

  it "raises a configuration error when no provider key is set" do
    organization = create(:organization)
    user = create(:user, organization: organization)
    engine = described_class.new(organization: organization, user: user)

    expect { engine.respond(history: [], content: "hi") }
      .to raise_error(Api::Error::UnprocessableEntity, /not configured/)
  end
end
