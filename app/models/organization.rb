# frozen_string_literal: true

class Organization < ApplicationRecord
  has_one :address, as: :recordable, class_name: "Address", dependent: :destroy
  has_many :users, dependent: :destroy
  belongs_to :owner, class_name: "User", optional: true

  PLAN_TYPES = %w[free pro enterprise].freeze

  before_create :generate_uuid

  validates :name, presence: true
  validates :plan, inclusion: { in: PLAN_TYPES }
  validates :subdomain,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 3 },
            format: { with: /\A[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\z/, message: "is invalid" }

  private

  def generate_uuid
    loop do
      self.uuid = SecureRandom.uuid
      break unless self.class.exists?(uuid: uuid)
    end
  end
end
