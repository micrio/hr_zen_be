# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def index?
    superadmin?
  end

  def create?
    superadmin?
  end

  def update?
    superadmin?
  end

  def destroy?
    superadmin?
  end

  private

  def superadmin?
    user&.has_role?("superadmin")
  end
end
