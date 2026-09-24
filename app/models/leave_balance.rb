# frozen_string_literal: true

class LeaveBalance < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :user
  belongs_to :leave_type

  validates :entitled_days, numericality: { greater_than_or_equal_to: 0 }
  validates :used_days, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: { scope: %i[organization_id leave_type_id] }

  def remaining_days
    entitled_days - used_days
  end
end
