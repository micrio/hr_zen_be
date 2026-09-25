# frozen_string_literal: true


class User < ApplicationRecord
  has_paper_trail meta: { organization_id: :organization_id }
  acts_as_tenant :organization

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable,
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :face_embeddings, dependent: :destroy
  has_many :attendance_events, dependent: :destroy
  has_many :leave_balances, dependent: :destroy
  has_many :leave_applications, dependent: :destroy
  has_many :compensations, dependent: :destroy
  has_many :performance_reviews, dependent: :destroy
  has_many :team_members, dependent: :destroy
  has_many :teams, through: :team_members
  has_many :led_teams, class_name: "Team", foreign_key: :lead_id, dependent: :nullify, inverse_of: :lead
  has_many :assigned_tasks, class_name: "Task", foreign_key: :assignee_id, dependent: :nullify, inverse_of: :assignee
  has_many :reviews_given, class_name: "PerformanceReview", foreign_key: :reviewer_id, dependent: :nullify, inverse_of: :reviewer
  has_many :payroll_entries, dependent: :destroy

  before_create :generate_uuid

  validates :first_name, :last_name, presence: true
  validates :age,
            numericality: { only_integer: true, greater_than: 0, less_than: 130 },
            allow_nil: true
  validates :gender, inclusion: { in: %w[male female other] }, allow_blank: true

  def full_name
    [ first_name, middle_name, last_name ].compact_blank.join(" ")
  end

  def assign_role(role_name)
    normalized_name = role_name.to_s.downcase.strip
    target_role = Role.find_by!(name: normalized_name)
    user_roles.find_or_create_by!(role: target_role)
  end

  def has_role?(role_name)
    user_roles.joins(:role).exists?(roles: { name: role_name.to_s.downcase.strip })
  end

  private

  def generate_uuid
    loop do
      self.uuid = SecureRandom.uuid
      break unless self.class.exists?(uuid: uuid)
    end
  end
end
