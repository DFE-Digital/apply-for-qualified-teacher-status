# frozen_string_literal: true

class AssessorInterface::ApplicationFormsExportPolicy < ApplicationPolicy
  def index?
    user.manage_staff_permission? && !user.archived?
  end
end
