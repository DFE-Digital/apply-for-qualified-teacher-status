# frozen_string_literal: true

class AssessorInterface::SuitabilityRecordPolicy < ApplicationPolicy
  def index?
    return false if user.archived?
    true
  end

  def create?
    user.assess_permission && !user.archived?
  end

  def update?
    user.assess_permission && !user.archived?
  end

  def destroy?
    user.assess_permission && !user.archived?
  end

  alias_method :archive?, :destroy?
end
