# frozen_string_literal: true

class AssessorInterface::AssessmentSectionPolicy < ApplicationPolicy
  def show?
    return false if user.archived?

    true
  end

  def update?
    user.assess_permission && !user.archived?
  end
end
