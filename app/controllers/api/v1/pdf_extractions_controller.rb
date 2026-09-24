# frozen_string_literal: true

module Api
  module V1
    class PdfExtractionsController < BaseController
      # POST /api/v1/pdf_extractions  (multipart: file=@profile.pdf)
      def create
        authorize :pdf_extraction, :create?

        file = params[:file]

        result = Api::V1::PdfProfileExtractor.new(
          io: file&.tempfile,
          filename: file&.original_filename,
          content_type: file&.content_type,
          byte_size: file&.size
        ).perform

        render_jsonapi(
          { fields: result[:fields] },
          meta: result[:meta].merge(message: "PDF parsed successfully.")
        )
      end
    end
  end
end
