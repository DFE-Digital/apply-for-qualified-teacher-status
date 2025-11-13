# frozen_string_literal: true

class AssessorInterface::ReferenceRequestPolicy < ApplicationPolicy
  def index?
    return false if user.archived?

    true
  end

  def update_review?
    user.assess_permission && !user.archived?
  end

  alias_method :edit_review?, :update_review?

  def update_verify?
    user.verify_permission && !user.archived?
  end

  def edit_verify?
    return false if user.archived?

    user.assess_permission ||
      user.change_work_history_and_qualification_permission ||
      user.verify_permission
  end

  def update_verify_failed?
    user.verify_permission && !user.archived?
  end

  alias_method :edit_verify_failed?, :update_verify_failed?

  def edit_resend_email?
    return false if user.archived?

    user.assess_permission || user.verify_permission
  end

  alias_method :update_resend_email?, :edit_resend_email?
  alias_method :resend_email_confirmation?, :edit_resend_email?
end
