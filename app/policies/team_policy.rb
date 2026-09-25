# frozen_string_literal: true

class TeamPolicy < ApplicationPolicy
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
    user&.admin?
  end
end
