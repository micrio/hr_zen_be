# frozen_string_literal: true


class AttendanceSetting < ApplicationRecord
  has_paper_trail meta: { organization_id: :organization_id }
  acts_as_tenant :organization

  DEFAULT_COOLDOWN_SECONDS = 60
  MAX_COOLDOWN_SECONDS = 24 * 60 * 60

  validates :cooldown_seconds,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: MAX_COOLDOWN_SECONDS
            }

  before_validation :ensure_clock_token, on: :create

  private

  def ensure_clock_token
    return if clock_token.present?

    loop do
      self.clock_token = SecureRandom.urlsafe_base64(24)
      break unless self.class.exists?(clock_token: clock_token)
    end
  end
end
