# frozen_string_literal: true

class CompensationPolicy < ApplicationPolicy
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
      user&.has_role?("superadmin")
    end
  end

  private

  def superadmin?
    user&.has_role?("superadmin")
  end
end
