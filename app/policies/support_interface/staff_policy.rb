# frozen_string_literal: true

class SupportInterface::StaffPolicy < ApplicationPolicy
  def index?
    user.support_console_permission? && !user.archived?
  end

  def update?
    user.support_console_permission? && !user.archived?
  end
end
