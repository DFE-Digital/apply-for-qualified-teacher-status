# frozen_string_literal: true

class AssessorInterface::AssessmentPolicy < ApplicationPolicy
  def update?
    user.assess_permission
  end

  def destroy?
    user.reverse_decision_permission
  end

  def rollback?
    destroy?
  end
end
