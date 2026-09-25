# frozen_string_literal: true

class Team < ApplicationRecord
  has_paper_trail meta: { organization_id: :organization_id }

  acts_as_tenant :organization

  belongs_to :lead, class_name: "User", optional: true
  has_many :team_members, dependent: :destroy
  has_many :members, through: :team_members, source: :user
  has_many :projects, dependent: :nullify

  validates :name, presence: true
  validates :name, uniqueness: { scope: :organization_id, case_sensitive: false }
end
