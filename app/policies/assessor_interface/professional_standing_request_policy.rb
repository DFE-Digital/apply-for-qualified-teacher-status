# frozen_string_literal: true

class AssessorInterface::ProfessionalStandingRequestPolicy < ApplicationPolicy
  def show?
    return false if user.archived?

    true
  end

  def update_locate?
    return false if user.archived?

    true
  end

  alias_method :edit_locate?, :update_locate?

  def update_request?
    user.verify_permission && !user.archived?
  end

  alias_method :edit_request?, :update_request?

  def update_verify?
    user.verify_permission && !user.archived?
  end

  alias_method :edit_verify?, :update_verify?

  def update_verify_failed?
    user.verify_permission && !user.archived?
  end

  alias_method :edit_verify_failed?, :update_verify_failed?

  def update_review?
    user.assess_permission && !user.archived?
  end

  alias_method :edit_review?, :update_review?
end
