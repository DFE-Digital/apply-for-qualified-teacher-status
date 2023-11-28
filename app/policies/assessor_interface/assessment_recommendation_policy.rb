# frozen_string_literal: true

class AssessorInterface::AssessmentRecommendationPolicy < ApplicationPolicy
  def show?
    user.assess_permission || user.verify_permission
  end

  def update?
    user.assess_permission || user.verify_permission
  end
end
