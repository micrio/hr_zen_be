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

  def self.limits_for(plan)
    { users: plan == "free" ? FREE_USER_LIMIT : nil }
  end

  # The full tier catalogue (platform admin plan picker).
  def self.plan_catalog
    PLAN_TYPES.map do |plan_name|
      {
        plan: plan_name,
        features: PLAN_FEATURES.fetch(plan_name, []),
        limits: limits_for(plan_name)
      }
    end
  end

  def limits
    self.class.limits_for(plan)
  end

  # Everything the client needs to gate UI: plan + allowed features + limits.
  def entitlements
    {
      plan: plan,
      features: PLAN_FEATURES.fetch(plan, []),
      limits: limits
    }
  end

  PLAN_TYPES = %w[free pro enterprise].freeze

  # Feature access per subscription tier.
  PLAN_FEATURES = {
    "free" => %w[users],
    "pro" => %w[
      users attendance leaves holidays payroll access_control records
      performance activities reports
    ],
    "enterprise" => %w[
      users attendance leaves holidays payroll access_control records
      performance activities reports work
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
