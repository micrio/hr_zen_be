# frozen_string_literal: true

module Api
  module V1
    class LeaveTypeSerializer < ActiveModel::Serializer
      attributes :id, :name, :default_days, :active, :created_at
    end
  end
end
