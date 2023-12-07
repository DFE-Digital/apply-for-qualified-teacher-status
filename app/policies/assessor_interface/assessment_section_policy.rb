# frozen_string_literal: true

class AssessorInterface::AssessmentSectionPolicy < ApplicationPolicy
  def show?
    true
  end

  def update?
    user.assess_permission
  end
end
