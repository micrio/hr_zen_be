# frozen_string_literal: true

class PermissionRule < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :role
  belongs_to :record_type

  validates :perm_level, presence: true, inclusion: { in: 0..9 }
  validates :perm_level, uniqueness: {
    scope: %i[organization_id role_id record_type_id],
    message: "rule already exists for this role and record type combination"
  }

  scope :readable, -> { where(can_read: true) }
  scope :writable, -> { where(can_write: true) }
  scope :creatable, -> { where(can_create: true) }
  scope :deletable, -> { where(can_delete: true) }
end
