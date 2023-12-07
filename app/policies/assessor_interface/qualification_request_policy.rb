# frozen_string_literal: true

class AssessorInterface::QualificationRequestPolicy < ApplicationPolicy
  def index?
    user.assess_permission || user.verify_permission
  end

  def update?
    user.assess_permission || user.verify_permission
  end
end
