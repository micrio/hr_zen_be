# frozen_string_literal: true

module Api
  module V1
    class ActivitiesController < BaseController
      plan_feature :activities

      # GET /api/v1/activities?user_id=&item_type=&from=&to=
      def index
        authorize :activity, :index?, policy_class: ActivityPolicy

        versions = Api::V1::ListActivitiesService.new(
          organization: current_user.organization,
          user_id: params[:user_id],
          item_type: params[:item_type],
          from: params[:from],
          to: params[:to]
        ).perform

        actors = User.where(id: versions.filter_map { |v| v.whodunnit&.to_i }.uniq)
                     .index_by(&:id)

        render_jsonapi(
          versions.map do |version|
            Api::V1::ActivitySerializer.new(version, actors: actors).serializable_hash
          end
        )
      end
    end
  end
end
