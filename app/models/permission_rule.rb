# frozen_string_literal: true


class PermissionRule < ApplicationRecord
  has_paper_trail meta: { organization_id: :organization_id }
  # Every boolean capability a rule can grant.
  ACTIONS = %i[
    can_read
    can_write
    can_create
    can_delete
    can_submit
    can_cancel
    can_amend
    can_export
    can_print
    apply_user_permissions
    can_set_user_permissions
  ].freeze

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
