# frozen_string_literal: true


class LeaveApplication < ApplicationRecord
  has_paper_trail meta: { organization_id: :organization_id }
  STATUSES = %w[pending approved rejected cancelled].freeze

  acts_as_tenant :organization

  belongs_to :user
  belongs_to :leave_type

  validates :start_date, :end_date, :days, presence: true
  validates :days, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: STATUSES }
  validate :end_date_after_start_date

  scope :recent_first, -> { order(start_date: :desc, created_at: :desc) }

  def approved?
    status == "approved"
  end

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?
    return if end_date >= start_date

    errors.add(:end_date, "must be on or after the start date")
  end
end
