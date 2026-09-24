# frozen_string_literal: true

module AuthHelper
  def bearer_token_for(user)
    Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
  end

  def auth_headers(user)
    { "Authorization" => "Bearer #{bearer_token_for(user)}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
  config.include AuthHelper, type: :controller
end
