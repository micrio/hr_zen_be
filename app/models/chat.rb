# frozen_string_literal: true

class Chat < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :user
  has_many :chat_messages, dependent: :destroy

  validates :title, presence: true

  scope :recent_first, -> { order(updated_at: :desc) }

  def touch_activity(title_from: nil)
    update!(title: title_from.to_s.strip.first(60)) if title_from.present? && default_title?
    touch
  end

  def default_title?
    title.blank? || title == "New chat"
  end
end
