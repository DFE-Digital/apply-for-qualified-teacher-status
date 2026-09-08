# frozen_string_literal: true

class AssessorInterface::ApplicationFormPolicy < ApplicationPolicy
  def index?
    return false if user.archived?

    true
  end

  alias_method :apply_filters?, :index?
  alias_method :apply_sort?, :index?
  alias_method :clear_filters?, :index?

  def show?
    return false if user.archived?

    true
  end

  alias_method :status?, :show?
  alias_method :timeline?, :show?

  def update_email?
    user.change_email_permission && !user.archived?
  end

  alias_method :edit_email?, :update_email?

  def update_name?
    user.change_name_permission && !user.archived?
  end

  alias_method :edit_name?, :update_name?
  alias_method :edit_date_of_birth?, :update_name?
  alias_method :update_date_of_birth?, :update_name?

  def destroy?
    user.withdraw_permission && !user.archived?
  end

  alias_method :withdraw?, :destroy?

  def edit_unlink_one_login?
    return false if user.archived?

    user.assess_permission || user.verify_permission
  end

  alias_method :update_unlink_one_login?, :edit_unlink_one_login?
end
