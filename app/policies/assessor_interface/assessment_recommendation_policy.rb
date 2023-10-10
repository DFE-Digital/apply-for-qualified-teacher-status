# frozen_string_literal: true

class AssessorInterface::AssessmentRecommendationPolicy < ApplicationPolicy
  def update?
    user.assess_permission || user.verify_permission
  end
end
