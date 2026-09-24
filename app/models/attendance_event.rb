# frozen_string_literal: true

class AttendanceEvent < ApplicationRecord
  KINDS = %w[clock_in clock_out].freeze

  acts_as_tenant :organization

  belongs_to :user

  validates :kind, inclusion: { in: KINDS }
  validates :occurred_at, presence: true

  scope :chronological, -> { order(occurred_at: :asc) }
  scope :recent_first, -> { order(occurred_at: :desc) }

  def self.for_day(day)
    where(occurred_at: day.to_date.all_day)
  end
end
