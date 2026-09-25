# frozen_string_literal: true

module Api
  module V1
    class PayrollEntrySerializer < ActiveModel::Serializer
      attributes :id, :user_id, :period_start, :period_end, :salary_type,
                 :rate, :units, :gross_amount, :net_amount, :adjustments,
                 :currency, :computed_at, :created_at

      attribute :user_name

      def user_name
        object.user&.full_name
      end

      %i[rate units gross_amount net_amount].each do |field|
        define_method(field) { object.public_send(field).to_f }
      end
    end
  end
end
