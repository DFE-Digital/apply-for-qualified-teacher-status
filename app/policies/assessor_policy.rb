# frozen_string_literal: true

class AssessorPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
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
end
