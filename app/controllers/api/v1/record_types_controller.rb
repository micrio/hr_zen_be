# frozen_string_literal: true

module Api
  module V1
    class RecordTypesController < BaseController
      plan_feature :access_control

      before_action :set_record_type, only: %i[show update destroy]

      # GET /api/v1/record_types
      def index
        authorize RecordType

        record_types = Api::V1::ListRecordTypesService.new.perform

        render_jsonapi(
          record_types.map do |record_type|
            Api::V1::RecordTypeSerializer.new(record_type).serializable_hash
          end
        )
      end

      # GET /api/v1/record_types/:id
      def show
        authorize @record_type

        render_jsonapi(
          Api::V1::RecordTypeSerializer.new(@record_type).serializable_hash
        )
      end

      # POST /api/v1/record_types
      def create
        authorize RecordType

        record_type = Api::V1::CreateRecordTypeService.new(
          attributes: record_type_params
        ).perform

        render_jsonapi(
          Api::V1::RecordTypeSerializer.new(record_type).serializable_hash,
          status: :created,
          meta: { message: "Record type created successfully." }
        )
      end

      # PATCH/PUT /api/v1/record_types/:id
      def update
        authorize @record_type

        record_type = Api::V1::UpdateRecordTypeService.new(
          record_type: @record_type,
          attributes: record_type_params
        ).perform

        render_jsonapi(
          Api::V1::RecordTypeSerializer.new(record_type).serializable_hash,
          meta: { message: "Record type updated successfully." }
        )
      end

      # DELETE /api/v1/record_types/:id
      def destroy
        authorize @record_type

        Api::V1::DeleteRecordTypeService.new(record_type: @record_type).perform

        render_jsonapi({}, meta: { message: "Record type deleted successfully." })
      end

      private

      def set_record_type
        @record_type = RecordType.find(params[:id])
      end

      def record_type_params
        params.require(:record_type).permit(
          :name,
          fields: [ :key, :label, :type, :level, :required, options: [] ]
        )
      end
    end
  end
end
