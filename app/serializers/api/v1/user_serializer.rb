# frozen_string_literal: true

module Api
  module V1
    class UserSerializer < ActiveModel::Serializer
      attributes :id, :uuid, :email, :first_name, :middle_name, :last_name,
                 :full_name, :confirmed_at, :created_at
    end
  end
end
