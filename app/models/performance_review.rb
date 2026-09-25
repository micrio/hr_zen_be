# frozen_string_literal: true

class PerformanceReview < ApplicationRecord
  STATUSES = %w[draft submitted acknowledged].freeze

  has_paper_trail meta: { organization_id: :organization_id }

  acts_as_tenant :organization

  belongs_to :user
  belongs_to :reviewer, class_name: "User", optional: true

  validates :status, inclusion: { in: STATUSES }
  validates :rating,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 },
            allow_nil: true
  validate :period_is_ordered

  scope :recent_first, -> { order(review_date: :desc, created_at: :desc) }

  private

  def period_is_ordered
    return if period_start.blank? || period_end.blank?
    return if period_end >= period_start

    errors.add(:period_end, "must be on or after the period start")
  end
end
