# frozen_string_literal: true


class RecordType < ApplicationRecord
  has_paper_trail meta: { organization_id: :organization_id }
  acts_as_tenant :organization

  has_many :permission_rules, dependent: :destroy
  has_many :record_entries, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :organization_id }

  # Flexible schema: array of field definitions.
  #
  #   [{ "key" => "salary", "label" => "Salary",
  #      "type" => "number", "level" => 1, "required" => false }]
  def field_definitions
    Array(fields)
  end

  def field_definition(key)
    wanted = key.to_s
    field_definitions.find { |field| field["key"].to_s == wanted }
  end

  # Sensitivity tier for a field (defaults to Level 0 when unmapped).
  def level_for_field(key)
    field_definition(key)&.fetch("level", 0).to_i
  end

  # Backwards-compatible view: { "field" => level }.
  def field_levels
    field_definitions.each_with_object({}) do |field, memo|
      memo[field["key"].to_s] = field["level"].to_i
    end
  end

  def field_keys
    field_definitions.map { |field| field["key"].to_s }
  end
end
