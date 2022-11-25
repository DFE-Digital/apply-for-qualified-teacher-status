# frozen_string_literal: true

class AssessorPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.award_decline_permission?
  end

  def update?
    user.award_decline_permission?
  end

  def destroy?
    user.award_decline_permission?
  end
end
