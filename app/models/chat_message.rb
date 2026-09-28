# frozen_string_literal: true

class ChatMessage < ApplicationRecord
  ROLES = %w[user assistant system].freeze

  acts_as_tenant :organization

  belongs_to :chat

  validates :role, inclusion: { in: ROLES }
  validates :content, presence: true

  scope :chronological, -> { order(:created_at, :id) }

  def references
    Array(metadata["references"])
  end
end
