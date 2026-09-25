# frozen_string_literal: true

# Gates a controller behind a plan feature:
#
#   class Api::V1::PayrollEntriesController < BaseController
#     plan_feature :payroll
#   end
module PlanGated
  extend ActiveSupport::Concern

  class_methods do
    def plan_feature(feature = nil)
      @plan_feature = feature if feature
      @plan_feature
    end
  end

  included do
    before_action :enforce_plan_feature
  end

  private

  def enforce_plan_feature
    feature = self.class.plan_feature
    return if feature.nil?

    organization = current_user&.organization
    return if organization.nil?
    return if organization.plan_allows?(feature)

    raise Api::Error::ForbiddenError,
          "Your #{organization.plan} plan does not include this feature."
  end
end
