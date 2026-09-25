# frozen_string_literal: true

module Api
  module V1
    class UpsertCompensationService
      ATTRS = %i[salary_type rate].freeze

      def initialize(args)
        @organization = args[:organization]
        @user = args[:user]
        @attributes = (args[:attributes] || {}).to_h.symbolize_keys.slice(*ATTRS)
      end

      def perform
        compensation = Compensation.find_or_initialize_by(
          organization: organization,
          user: user
        )
        compensation.assign_attributes(attributes)
        compensation.save!
        compensation
      end

      private

      attr_reader :organization, :user, :attributes
    end
  end
end
