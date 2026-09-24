# frozen_string_literal: true

class AttendanceSettingPolicy < ApplicationPolicy
  def show?
    superadmin?
  end

  def update?
    superadmin?
  end

  private

  def superadmin?
    user&.has_role?("superadmin")
  end
end
