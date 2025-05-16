# frozen_string_literal: true

class AssessorInterface::StaffPolicy < ApplicationPolicy
  def index?
    user.manage_staff_permission? && !user.archived?
  end

  def update?
    user.manage_staff_permission? && !user.archived?
  end

  def edit_archive?
    user.manage_staff_permission? && !user.archived?
  end

  def update_archive?
    user.manage_staff_permission? && !user.archived?
  end

  def edit_unarchive?
    user.manage_staff_permission? && !user.archived?
  end

  def update_unarchive?
    user.manage_staff_permission? && !user.archived?
  end
end
