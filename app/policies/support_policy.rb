# frozen_string_literal: true

class SupportPolicy < ApplicationPolicy
  def index?
    user.support_console_permission?
  end

  def show?
    user.support_console_permission?
  end

  def create?
    user.support_console_permission?
  end

  def update?
    user.support_console_permission?
  end

  def destroy?
    user.support_console_permission?
  end
end
