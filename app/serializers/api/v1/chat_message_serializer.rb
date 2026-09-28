# frozen_string_literal: true

module Api
  module V1
    class ChatMessageSerializer < ActiveModel::Serializer
      attributes :id, :role, :content, :metadata, :created_at
    end
  end
end
