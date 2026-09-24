# frozen_string_literal: true

module Api
  module V1
    class UserSerializer < ActiveModel::Serializer
      attributes :id, :uuid, :email, :first_name, :middle_name, :last_name,
                 :full_name, :age, :gender, :confirmed_at, :created_at, :role_names, :custom_fields

      def role_names
        object.roles.pluck(:name)
      end
    end
  end
end
