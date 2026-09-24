# frozen_string_literal: true

class FaceEmbedding < ApplicationRecord
  acts_as_tenant :organization

  belongs_to :user

  before_validation :set_dimension

  validates :vector, presence: true
  validates :dimension, numericality: { greater_than: 0 }
  validate :vector_is_numeric_array

  scope :recent_first, -> { order(created_at: :desc) }

  private

  def set_dimension
    self.dimension = Array(vector).length
  end

  def vector_is_numeric_array
    values = Array(vector)
    return if values.length.between?(32, 2048) && values.all? { |value| value.is_a?(Numeric) }

    errors.add(:vector, "must be an array of 32..2048 numbers")
  end
end
