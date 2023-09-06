# frozen_string_literal: true

class AssessorInterface::ApplicationFormPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def update?
    user.change_name_permission
  end

  def destroy?
    user.withdraw_permission
  end

  def withdraw?
    destroy?
  end
end
