# frozen_string_literal: true

class AssessorInterface::PrioritisationReferenceRequestPolicy < ApplicationPolicy
  def index?
    return false if user.archived?

    true
  end

  def confirmation?
    return false if user.archived?

    true
  end

  def create?
    user.assess_permission && !user.archived?
  end

  def update?
    user.assess_permission && !user.archived?
  end
end
