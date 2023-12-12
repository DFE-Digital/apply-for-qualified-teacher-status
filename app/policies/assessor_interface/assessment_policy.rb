# frozen_string_literal: true

class AssessorInterface::AssessmentPolicy < ApplicationPolicy
  def review?
    user.assess_permission || user.verify_permission
  end

  def destroy?
    user.reverse_decision_permission
  end

  def rollback?
    destroy?
  end
end
