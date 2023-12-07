# frozen_string_literal: true

class AssessorInterface::ApplicationFormPolicy < ApplicationPolicy
  def index?
    true
  end

  alias_method :apply_filters?, :index?
  alias_method :clear_filters?, :index?

  def show?
    true
  end

  alias_method :status?, :show?
  alias_method :timeline?, :show?

  def update?
    user.change_name_permission
  end

  def destroy?
    user.withdraw_permission
  end

  alias_method :withdraw?, :destroy?
end
