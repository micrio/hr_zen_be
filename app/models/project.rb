# frozen_string_literal: true

class Project < ApplicationRecord
  STATUSES = %w[active on_hold completed archived].freeze

  has_paper_trail meta: { organization_id: :organization_id }

  acts_as_tenant :organization

  belongs_to :team, optional: true
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :organization_id, case_sensitive: false }
  validates :status, inclusion: { in: STATUSES }
  validate :dates_are_ordered

  scope :recent_first, -> { order(created_at: :desc) }

  private

  def dates_are_ordered
    return if start_date.blank? || end_date.blank?
    return if end_date >= start_date

    errors.add(:end_date, "must be on or after the start date")
  end
end
