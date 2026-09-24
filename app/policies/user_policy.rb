# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    superadmin?
  end

  def show?
    superadmin? || own_record?
  end

  def create?
    superadmin?
  end

  def update?
    superadmin? || own_record?
  end

  def destroy?
    superadmin? && !own_record?
  end

  def confirm?
    superadmin?
  end

  def manage_face?
    superadmin? || own_record?
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

  def own_record?
    record.present? && record.respond_to?(:id) && record.id == user&.id
  end
end
