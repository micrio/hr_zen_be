# frozen_string_literal: true

class TeamMember < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :team
  belongs_to :user

  validates :user_id, uniqueness: { scope: :team_id }
end
