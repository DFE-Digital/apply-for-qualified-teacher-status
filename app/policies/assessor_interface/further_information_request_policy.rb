# frozen_string_literal: true

class AssessorInterface::FurtherInformationRequestPolicy < ApplicationPolicy
  def create?
    user.assess_permission
  end

  def update?
    user.assess_permission
  end

  def edit?
    true
  end
end
