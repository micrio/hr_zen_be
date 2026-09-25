# frozen_string_literal: true


class RecordEntry < ApplicationRecord
  has_paper_trail meta: { organization_id: :organization_id }
  acts_as_tenant :organization

  belongs_to :record_type

  before_validation :generate_uuid, on: :create

  validates :uuid, presence: true, uniqueness: true

  def field(key)
    data.to_h[key.to_s]
  end

  private

  def generate_uuid
    loop do
      self.uuid = SecureRandom.uuid
      break unless self.class.exists?(uuid: uuid)
    end
  end
end
