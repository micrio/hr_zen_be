# frozen_string_literal: true

class PayrollSetting < ApplicationRecord
  SALARY_TYPES = %w[hourly daily monthly].freeze
  FREQUENCIES = %w[weekly semi_monthly monthly].freeze

  acts_as_tenant :organization

  validates :currency, presence: true
  validates :default_salary_type, inclusion: { in: SALARY_TYPES }
  validates :pay_frequency, inclusion: { in: FREQUENCIES }
end
