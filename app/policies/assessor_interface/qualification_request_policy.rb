# frozen_string_literal: true

class AssessorInterface::QualificationRequestPolicy < ApplicationPolicy
  def index?
    true
  end

  def update?
    user.assess_permission
  end
end
