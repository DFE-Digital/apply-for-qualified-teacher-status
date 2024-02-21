# frozen_string_literal: true

class AssessorInterface::ConsentRequestPolicy < ApplicationPolicy
  def create?
    user.verify_permission
  end

  def update_upload?
    user.verify_permission
  end

  alias_method :edit_upload?, :update_upload?

  def update_review?
    user.assess_permission
  end

  alias_method :edit_review?, :update_review?
end
