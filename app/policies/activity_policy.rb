# frozen_string_literal: true

class ActivityPolicy < ApplicationPolicy
  def index?
    superadmin?
  end

  private

  def superadmin?
    user&.admin?
  end
end
