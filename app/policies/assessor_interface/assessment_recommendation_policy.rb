# frozen_string_literal: true

class AssessorInterface::AssessmentRecommendationPolicy < ApplicationPolicy
  def show?
    return false if user.archived?

    user.assess_permission || user.verify_permission
  end

  def update?
    return false if user.archived?

    user.assess_permission || user.verify_permission
  end
end
