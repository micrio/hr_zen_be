# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_tenant :organization

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable,
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  before_create :generate_uuid

  validates :first_name, :last_name, presence: true

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
