# frozen_string_literal: true

module Api
  module V1
    class RolesController < BaseController
      plan_feature :access_control

      before_action :set_role, only: %i[show update destroy]

      # GET /api/v1/roles
      def index
        authorize Role

        roles = Api::V1::ListRolesService.new.perform

        render_jsonapi(
          roles.map { |role| Api::V1::RoleSerializer.new(role).serializable_hash }
        )
      end

      # GET /api/v1/roles/:id
      def show
        authorize @role

        render_jsonapi(Api::V1::RoleSerializer.new(@role).serializable_hash)
      end

      # POST /api/v1/roles
      def create
        authorize Role

        role = Api::V1::CreateRoleService.new(attributes: role_params).perform

        render_jsonapi(
          Api::V1::RoleSerializer.new(role).serializable_hash,
          status: :created,
          meta: { message: "Role created successfully." }
        )
      end

      # PATCH/PUT /api/v1/roles/:id
      def update
        authorize @role

        role = Api::V1::UpdateRoleService.new(
          role: @role,
          attributes: role_params
        ).perform

        render_jsonapi(
          Api::V1::RoleSerializer.new(role).serializable_hash,
          meta: { message: "Role updated successfully." }
        )
      end

      # DELETE /api/v1/roles/:id
      def destroy
        authorize @role

        Api::V1::DeleteRoleService.new(role: @role).perform

        render_jsonapi({}, meta: { message: "Role deleted successfully." })
      end

      private

      def set_role
        @role = Role.find(params[:id])
      end

      def role_params
        params.require(:role).permit(:name)
      end
    end
  end
end
