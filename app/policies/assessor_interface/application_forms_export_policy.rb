# frozen_string_literal: true

class AssessorInterface::ApplicationFormsExportPolicy < ApplicationPolicy
  def index?
    return false if user.archived?

    true
  end
end
