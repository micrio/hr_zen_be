# frozen_string_literal: true

class UserRole < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :user
  belongs_to :role
end
