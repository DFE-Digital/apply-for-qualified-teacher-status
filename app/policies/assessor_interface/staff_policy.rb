# frozen_string_literal: true

class AssessorInterface::StaffPolicy < ApplicationPolicy
  def index?
    user.manage_staff_permission? && !user.archived?
  end

  def update?
    user.manage_staff_permission? && !user.archived?
  end

  def alert?
    user.manage_staff_permission? && !user.archived?
  end

  def archive?
    user.manage_staff_permission? && !user.archived?
  end
end
