# frozen_string_literal: true

class AssessorInterface::AssessmentPolicy < ApplicationPolicy
  def review?
    return false if user.archived?

    user.assess_permission || user.verify_permission
  end

  def destroy?
    user.reverse_decision_permission && !user.archived?
  end

  def rollback?
    destroy? && !user.archived?
  end

  def edit_prioritisation?
    return false if user.archived?

    user.assess_permission || user.verify_permission
  end

  def update_prioritisation?
    return false if user.archived?

    user.assess_permission || user.verify_permission
  end

  def confirm_prioritisation?
    return false if user.archived?

    user.assess_permission || user.verify_permission
  end
end
