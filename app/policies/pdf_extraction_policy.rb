# frozen_string_literal: true

class PdfExtractionPolicy < ApplicationPolicy
  def create?
    superadmin?
  end

  private

  def superadmin?
    user&.admin?
  end
end
