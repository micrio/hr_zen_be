# frozen_string_literal: true

module Api
  module V1
    class RecordEntriesController < BaseController
      plan_feature :records

      before_action :set_record_entry, only: %i[show update destroy]

      # GET /api/v1/record_entries?record_type_id=
      def index
        authorize RecordEntry

        entries = Api::V1::ListRecordEntriesService.new(
          record_type_id: params[:record_type_id]
        ).perform

        render_jsonapi(
          entries.map do |entry|
            Api::V1::RecordEntrySerializer.new(entry).serializable_hash
          end
        )
      end

      # GET /api/v1/record_entries/:id
      def show
        authorize @record_entry

        render_jsonapi(
          Api::V1::RecordEntrySerializer.new(@record_entry).serializable_hash
        )
      end

      # POST /api/v1/record_entries
      def create
        authorize RecordEntry

        entry = Api::V1::CreateRecordEntryService.new(
          record_type: record_type,
          data: entry_params[:data]
        ).perform

        render_jsonapi(
          Api::V1::RecordEntrySerializer.new(entry).serializable_hash,
          status: :created,
          meta: { message: "Record created successfully." }
        )
      end

      # PATCH/PUT /api/v1/record_entries/:id
      def update
        authorize @record_entry

        entry = Api::V1::UpdateRecordEntryService.new(
          record_entry: @record_entry,
          data: entry_params[:data]
        ).perform

        render_jsonapi(
          Api::V1::RecordEntrySerializer.new(entry).serializable_hash,
          meta: { message: "Record updated successfully." }
        )
      end

      # DELETE /api/v1/record_entries/:id
      def destroy
        authorize @record_entry

        Api::V1::DeleteRecordEntryService.new(record_entry: @record_entry).perform

        render_jsonapi({}, meta: { message: "Record deleted successfully." })
      end

      private

      def set_record_entry
        @record_entry = RecordEntry.find(params[:id])
      end

      def record_type
        @record_type ||= RecordType.find(entry_params[:record_type_id])
      end

      def entry_params
        params.require(:record_entry).permit(:record_type_id, data: {})
      end
    end
  end
end
