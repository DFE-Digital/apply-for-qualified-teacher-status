# frozen_string_literal: true

class AssessorInterface::ReferenceRequestPolicy < ApplicationPolicy
  def index?
    user.assess_permission
  end

  def update_verify_references?
    user.assess_permission
  end

  def update?
    user.assess_permission
  end

  def edit?
    user.assess_permission || user.change_work_history_permission
  end
end
