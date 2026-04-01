# frozen_string_literal: true

class AssessorInterface::DecisionReviewRequestPolicy < ApplicationPolicy
  def update?
    return false if user.archived?

    user.reverse_decision_permission
  end

  alias_method :edit?, :update?
  alias_method :edit_confirm?, :update?
  alias_method :update_confirm?, :update?
  alias_method :confirmation?, :update?
end
