# frozen_string_literal: true

class AssessorInterface::ReferenceRequestPolicy < ApplicationPolicy
  def index?
    true
  end

  def update_review?
    user.assess_permission
  end

  alias_method :edit_review?, :update_review?

  def update_verify?
    user.verify_permission
  end

  def edit_verify?
    user.assess_permission || user.change_work_history_permission ||
      user.verify_permission
  end

  def update_verify_failed?
    user.verify_permission
  end

  alias_method :edit_verify_failed?, :update_verify_failed?
end
