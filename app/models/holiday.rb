# frozen_string_literal: true

class Holiday < ApplicationRecord
  has_paper_trail meta: { organization_id: :organization_id }

  acts_as_tenant :organization

  validates :name, presence: true
  validates :date, presence: true
  validates :date, uniqueness: { scope: :organization_id }

  scope :chronological, -> { order(:date) }

  def self.for_year(year)
    return chronological if year.blank?

    where(date: Date.new(year.to_i, 1, 1)..Date.new(year.to_i, 12, 31))
      .or(where(recurring: true))
      .chronological
  end
end
