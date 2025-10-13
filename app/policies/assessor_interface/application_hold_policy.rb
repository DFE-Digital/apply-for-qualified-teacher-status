# frozen_string_literal: true

class AssessorInterface::ApplicationHoldPolicy < ApplicationPolicy
  def create?
    (user.assess_permission || user.verify_permission) && !user.archived?
  end

  alias_method :new?, :create?
  alias_method :new_submit?, :create?
  alias_method :new_confirm?, :create?
  alias_method :edit?, :create?
  alias_method :edit_submit?, :create?
  alias_method :edit_confirm?, :create?
  alias_method :update?, :create?
  alias_method :confirmation?, :create?
end
