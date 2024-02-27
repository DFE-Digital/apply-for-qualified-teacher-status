# frozen_string_literal: true

class AssessorInterface::ConsentRequestPolicy < ApplicationPolicy
  def create?
    user.verify_permission
  end

  def update_request?
    user.verify_permission
  end

  alias_method :edit_request?, :update_request?

  def update_upload?
    user.verify_permission
  end

  alias_method :edit_upload?, :update_upload?

  def update_verify?
    user.verify_permission
  end

  alias_method :edit_verify?, :update_verify?

  def update_verify_failed?
    user.verify_permission
  end

  alias_method :edit_verify_failed?, :update_verify_failed?

  def update_review?
    user.assess_permission
  end

  alias_method :edit_review?, :update_review?
end
