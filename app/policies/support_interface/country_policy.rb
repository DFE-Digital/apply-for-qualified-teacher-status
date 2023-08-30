# frozen_string_literal: true

class SupportInterface::CountryPolicy < ApplicationPolicy
  def index?
    user.support_console_permission?
  end

  def confirm_edit?
    user.support_console_permission?
  end

  def update?
    user.support_console_permission?
  end
end
