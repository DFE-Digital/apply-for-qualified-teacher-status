# frozen_string_literal: true

class SupportInterface::RegionPolicy < ApplicationPolicy
  def update?
    user.support_console_permission?
  end

  def preview?
    user.support_console_permission?
  end
end
