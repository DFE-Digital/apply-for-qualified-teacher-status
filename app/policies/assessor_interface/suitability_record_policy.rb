# frozen_string_literal: true

class AssessorInterface::SuitabilityRecordPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    user.assess_permission
  end

  def update?
    user.assess_permission
  end

  def destroy?
    user.assess_permission
  end

  alias_method :archive?, :destroy?
end
