# frozen_string_literal: true

class SetupWorkspaceJob < ApplicationJob
  queue_as :priority

  def perform(organization_id)
    organization = Organization.find(organization_id)
    AuthMatrix::Initializer.setup_workspace!(organization)
  end
end
