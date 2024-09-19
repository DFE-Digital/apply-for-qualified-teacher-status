# frozen_string_literal: true

class SupportInterface::CountryPolicy < ApplicationPolicy
  def index?
    user.support_console_permission? && !user.archived?
  end

  def update?
    user.support_console_permission? && !user.archived?
  end

  def preview?
    user.support_console_permission? && !user.archived?
  end
end
