# frozen_string_literal: true

class AssessorInterface::AssessmentRecommendationPolicy < ApplicationPolicy
  def update?
    user.award_decline_permission || user.verify_permission
  end
end
