# frozen_string_literal: true

module Api
  module V1
    class OrganizationSerializer < ActiveModel::Serializer
      attributes :id, :uuid, :name, :email, :phone, :subdomain, :status, :created_at
    end
  end
end
