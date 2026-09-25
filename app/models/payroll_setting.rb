# frozen_string_literal: true

class PayrollSetting < ApplicationRecord
  SALARY_TYPES = %w[hourly daily monthly].freeze

  acts_as_tenant :organization

  validates :currency, presence: true
  validates :default_salary_type, inclusion: { in: SALARY_TYPES }
end
