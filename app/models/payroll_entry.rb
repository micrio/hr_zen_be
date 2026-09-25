# frozen_string_literal: true

class PayrollEntry < ApplicationRecord
  SALARY_TYPES = %w[hourly daily monthly].freeze

  acts_as_tenant :organization

  belongs_to :user

  validates :period_start, :period_end, :salary_type, presence: true
  validates :salary_type, inclusion: { in: SALARY_TYPES }

  scope :recent_first, -> { order(period_end: :desc, created_at: :desc) }

  def adjustments_total(kind)
    Array(adjustments).select { |row| row["kind"] == kind }
                      .sum { |row| row["amount"].to_f }
  end
end
