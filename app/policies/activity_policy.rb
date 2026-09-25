# frozen_string_literal: true

class ActivityPolicy < ApplicationPolicy
  def index?
    superadmin?
  end

  private

  def superadmin?
    user&.has_role?("superadmin")
  end
end
