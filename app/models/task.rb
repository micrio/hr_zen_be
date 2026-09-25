# frozen_string_literal: true

class Task < ApplicationRecord
  STATUSES = %w[todo in_progress blocked done].freeze
  PRIORITIES = %w[low medium high urgent].freeze

  has_paper_trail meta: { organization_id: :organization_id }

  acts_as_tenant :organization

  belongs_to :project
  belongs_to :assignee, class_name: "User", optional: true

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }

  scope :recent_first, -> { order(due_date: :asc, created_at: :desc) }
end
