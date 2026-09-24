# frozen_string_literal: true

class RecordType < ApplicationRecord
  acts_as_tenant :organization

  has_many :permission_rules, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :organization_id }

  # Returns the sensitivity tier for a field. Unmapped fields default to Level 0.
  def level_for_field(field_name)
    return 0 if field_levels.blank?

    field_levels[field_name.to_s].to_i
  end
end
