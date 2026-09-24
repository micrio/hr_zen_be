# frozen_string_literal: true

module Api
  module V1
    class PermissionRulesController < BaseController
      before_action :set_permission_rule, only: %i[show update destroy]

      # GET /api/v1/permission_rules?role_id=&record_type_id=
      def index
        authorize PermissionRule

        rules = Api::V1::ListPermissionRulesService.new(
          role_id: params[:role_id],
          record_type_id: params[:record_type_id]
        ).perform

        render_jsonapi(
          rules.map do |rule|
            Api::V1::PermissionRuleSerializer.new(rule).serializable_hash
          end
        )
      end

      # GET /api/v1/permission_rules/:id
      def show
        authorize @permission_rule

        render_jsonapi(
          Api::V1::PermissionRuleSerializer.new(@permission_rule).serializable_hash
        )
      end

      # POST /api/v1/permission_rules
      def create
        authorize PermissionRule

        rule = Api::V1::CreatePermissionRuleService.new(
          attributes: permission_rule_params
        ).perform

        render_jsonapi(
          Api::V1::PermissionRuleSerializer.new(rule).serializable_hash,
          status: :created,
          meta: { message: "Permission rule created successfully." }
        )
      end

      # PATCH/PUT /api/v1/permission_rules/:id
      def update
        authorize @permission_rule

        rule = Api::V1::UpdatePermissionRuleService.new(
          permission_rule: @permission_rule,
          attributes: permission_rule_params
        ).perform

        render_jsonapi(
          Api::V1::PermissionRuleSerializer.new(rule).serializable_hash,
          meta: { message: "Permission rule updated successfully." }
        )
      end

      # DELETE /api/v1/permission_rules/:id
      def destroy
        authorize @permission_rule

        Api::V1::DeletePermissionRuleService.new(
          permission_rule: @permission_rule
        ).perform

        render_jsonapi(
          {},
          meta: { message: "Permission rule deleted successfully." }
        )
      end

      private

      def set_permission_rule
        @permission_rule = PermissionRule.find(params[:id])
      end

      def permission_rule_params
        params.require(:permission_rule).permit(
          :role_id,
          :record_type_id,
          :perm_level,
          *PermissionRule::ACTIONS
        )
      end
    end
  end
end
