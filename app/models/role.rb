# frozen_string_literal: true

class Role < ApplicationRecord
  # Automatically scopes queries and injects organization_id on save.
  acts_as_tenant :organization

  has_many :permission_rules, dependent: :destroy
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  validates :name, presence: true
  validates :name, uniqueness: { scope: :organization_id, case_sensitive: false }

  before_save { self.name = name.downcase.strip }
end
