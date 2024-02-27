# frozen_string_literal: true

class AssessorInterface::FurtherInformationRequestPolicy < ApplicationPolicy
  def create?
    user.assess_permission
  end

  alias_method :preview?, :new?

  def update?
    user.assess_permission
  end

  def edit?
    true
  end
end
