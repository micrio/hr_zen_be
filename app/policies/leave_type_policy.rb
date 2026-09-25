# frozen_string_literal: true

class LeaveTypePolicy < ApplicationPolicy
  def index?
    superadmin?
  end

  def show?
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

  class Scope < Scope
    def resolve
      superadmin? ? scope.all : scope.none
    end

    private

    def superadmin?
      user&.admin?
    end
  end

  private

  def superadmin?
    user&.admin?
  end
end
