# frozen_string_literal: true

module Api
  module V1
    class RecordEntrySerializer < ActiveModel::Serializer
      attributes :id, :uuid, :record_type_id, :data, :created_at, :updated_at
    end
  end
end
