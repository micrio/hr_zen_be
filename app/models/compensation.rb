# frozen_string_literal: true


class Compensation < ApplicationRecord
  has_paper_trail meta: { organization_id: :organization_id }
  SALARY_TYPES = %w[hourly daily monthly].freeze

  acts_as_tenant :organization

  belongs_to :user

  validates :salary_type, inclusion: { in: SALARY_TYPES }
  validates :rate, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: { scope: :organization_id }
end
