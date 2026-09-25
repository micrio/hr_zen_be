# frozen_string_literal: true

require "rails_helper"

# Guards the plan gate map: every gated controller must declare a feature that
# exists, and every controller must be gated or explicitly listed as ungated.
RSpec.describe "Plan feature registry" do
  UNGATED = %w[
    Api::V1::BaseController
    Api::V1::RegistrationsController
    Api::V1::SessionsController
    Api::V1::KioskController
    Api::V1::OrganizationsController
    Api::V1::EntitlementsController
    Api::V1::PlansController
  ].freeze

  def controller_constants
    Dir[Rails.root.join("app/controllers/api/v1/**/*_controller.rb")].map do |path|
      path
        .sub("#{Rails.root.join('app/controllers')}/", "")
        .sub(/\.rb\z/, "")
        .camelize
    end.sort
  end

  it "finds controllers to check" do
    expect(controller_constants).to include("Api::V1::TasksController")
  end

  it "declares only known plan features" do
    controller_constants.each do |name|
      feature = name.constantize.plan_feature
      next if feature.nil?

      expect(Organization::ALL_FEATURES).to include(feature.to_s),
                                            "#{name} declares unknown plan feature #{feature.inspect}"
    end
  end

  it "gates every controller or lists it as ungated" do
    controller_constants.each do |name|
      feature = name.constantize.plan_feature
      next if feature

      expect(UNGATED).to include(name),
                     "#{name} has no plan_feature and is not in UNGATED"
    end
  end
end
