# frozen_string_literal: true

class AssessorInterface::WorkHistoryPolicy < ApplicationPolicy
  def update?
    user.manage_applications_permission
  end
end
