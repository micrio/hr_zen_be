# frozen_string_literal: true

module Api
  module V1
    class ListLeaveTypesService
      def perform
        LeaveType.order(:name)
      end
    end
  end
end
