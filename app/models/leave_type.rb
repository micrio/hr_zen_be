# frozen_string_literal: true

class LeaveType < ApplicationRecord
  acts_as_tenant :organization

  has_many :leave_balances, dependent: :destroy
  has_many :leave_applications, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :organization_id, case_sensitive: false }
  validates :default_days, numericality: { greater_than_or_equal_to: 0 }

  before_save { self.name = name.to_s.strip }
end
