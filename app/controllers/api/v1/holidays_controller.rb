# frozen_string_literal: true

module Api
  module V1
    class HolidaysController < BaseController
      plan_feature :holidays

      before_action :set_holiday, only: %i[update destroy]

      # GET /api/v1/holidays?year=
      def index
        authorize Holiday

        holidays = Api::V1::ListHolidaysService.new(year: params[:year]).perform

        render_jsonapi(
          holidays.map do |holiday|
            Api::V1::HolidaySerializer.new(holiday).serializable_hash
          end
        )
      end

      # POST /api/v1/holidays
      def create
        authorize Holiday

        holiday = Api::V1::CreateHolidayService.new(
          attributes: holiday_params
        ).perform

        render_jsonapi(
          Api::V1::HolidaySerializer.new(holiday).serializable_hash,
          status: :created,
          meta: { message: "Holiday created successfully." }
        )
      end

      # PATCH /api/v1/holidays/:id
      def update
        authorize @holiday

        holiday = Api::V1::UpdateHolidayService.new(
          holiday: @holiday,
          attributes: holiday_params
        ).perform

        render_jsonapi(
          Api::V1::HolidaySerializer.new(holiday).serializable_hash,
          meta: { message: "Holiday updated successfully." }
        )
      end

      # DELETE /api/v1/holidays/:id
      def destroy
        authorize @holiday

        Api::V1::DeleteHolidayService.new(holiday: @holiday).perform

        render_jsonapi({}, meta: { message: "Holiday deleted successfully." })
      end

      private

      def set_holiday
        @holiday = Holiday.find(params[:id])
      end

      def holiday_params
        params.require(:holiday).permit(:name, :date, :recurring)
      end
    end
  end
end
