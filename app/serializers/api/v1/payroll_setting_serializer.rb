# frozen_string_literal: true

module Api
  module V1
    class PayrollSettingSerializer < ActiveModel::Serializer
      attributes :id, :currency, :default_salary_type, :pay_frequency
    end
  end
end
