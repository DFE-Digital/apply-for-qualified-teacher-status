# frozen_string_literal: true

class SupportInterface::CountryPolicy < ApplicationPolicy
  def index?
    user.support_console_permission?
  end

  def update?
    user.support_console_permission?
  end

  def preview?
    user.support_console_permission?
  end
end
