# frozen_string_literal: true

class AssessorInterface::StaffAssignmentPolicy < ApplicationPolicy
  def create?
    user.assess_permission
  end
end
