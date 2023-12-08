# frozen_string_literal: true

class AssessorInterface::ReferenceRequestPolicy < ApplicationPolicy
  def index?
    true
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

  def update_review?
    user.assess_permission
  end

  alias_method :edit_review?, :update_review?
end
