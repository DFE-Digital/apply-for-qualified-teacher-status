# frozen_string_literal: true

class AssessorInterface::EligibilityDomainPolicy < ApplicationPolicy
  def index?
    user.support_console_permission && !user.archived?
  end

  alias_method :applications?, :index?
  alias_method :create?, :index?
  alias_method :edit?, :index?
  alias_method :update?, :index?
  alias_method :edit_archive?, :index?
  alias_method :update_archive?, :index?
  alias_method :edit_reactivate?, :index?
  alias_method :update_reactivate?, :index?
end
