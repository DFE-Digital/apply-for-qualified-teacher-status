# frozen_string_literal: true

class AssessorInterface::PrioritisationWorkHistoryCheckPolicy < ApplicationPolicy
  def index?
    return false if user.archived?

    true
  end

  def update?
    user.assess_permission && !user.archived?
  end
end
