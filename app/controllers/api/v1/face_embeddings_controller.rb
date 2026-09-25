# frozen_string_literal: true

module Api
  module V1
    class FaceEmbeddingsController < BaseController
      plan_feature :attendance

      before_action :set_user

      # GET /api/v1/users/:user_id/face
      def show
        authorize @user

        render_jsonapi(face_status)
      end

      # POST /api/v1/users/:user_id/face
      def create
        authorize @user, :manage_face?

        Api::V1::RegisterFaceService.new(
          user: @user,
          embedding: face_params[:embedding],
          source: face_params[:source]
        ).perform

        render_jsonapi(
          face_status,
          status: :created,
          meta: { message: "Face registered successfully." }
        )
      end

      # DELETE /api/v1/users/:user_id/face
      def destroy
        authorize @user, :manage_face?

        Api::V1::DeleteFaceService.new(user: @user).perform

        render_jsonapi(face_status, meta: { message: "Face data removed." })
      end

      private

      def set_user
        @user = User.find(params[:user_id])
      end

      def face_params
        params.require(:face).permit(:source, embedding: [])
      end

      def face_status
        embeddings = @user.face_embeddings
        {
          registered: embeddings.any?,
          count: embeddings.size,
          updated_at: embeddings.maximum(:updated_at)
        }
      end
    end
  end
end
