# frozen_string_literal: true

module Api
  module V1
    class HolidaySerializer < ActiveModel::Serializer
      attributes :id, :name, :date, :recurring, :created_at
    end
  end
end
