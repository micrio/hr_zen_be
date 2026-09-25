# frozen_string_literal: true

class Organization < ApplicationRecord
  has_one :address, as: :recordable, class_name: "Address", dependent: :destroy
  has_many :users, dependent: :destroy
  belongs_to :owner, class_name: "User", optional: true

  def plan_allows?(feature)
    (PLAN_FEATURES[plan] || []).include?(feature.to_s)
  end

  def user_limit
    plan == "free" ? FREE_USER_LIMIT : nil
  end

  def user_limit_reached?
    limit = user_limit
    limit.present? && users.count >= limit
  end

  # Everything the client needs to gate UI: plan + allowed features + limits.
  def entitlements
    {
      plan: plan,
      features: PLAN_FEATURES.fetch(plan, []),
      limits: { users: user_limit }
    }
  end

  PLAN_TYPES = %w[free pro enterprise].freeze

  # Feature access per subscription tier.
  PLAN_FEATURES = {
    "free" => %w[users],
    "pro" => %w[
      users attendance leaves holidays payroll access_control records
      performance activities
    ],
    "enterprise" => %w[
      users attendance leaves holidays payroll access_control records
      performance activities work
    ]
  }.freeze

  FREE_USER_LIMIT = 5

  ALL_FEATURES = PLAN_FEATURES.values.flatten.uniq.freeze

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
