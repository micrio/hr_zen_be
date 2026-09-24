# frozen_string_literal: true

module ApiHelper
  def response_body
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include ApiHelper, type: :request
  config.include ApiHelper, type: :controller
end
