# frozen_string_literal: true

class AssessorInterface::QualificationRequestPolicy < ApplicationPolicy
  def index?
    return false if user.archived?

    true
  end

  def index_consent_methods?
    user.verify_permission && !user.archived?
  end

  def check_consent_methods?
    user.verify_permission && !user.archived?
  end

  def update_unsigned_consent_document?
    user.verify_permission && !user.archived?
  end

  alias_method :edit_unsigned_consent_document?,
               :update_unsigned_consent_document?

  def generate_unsigned_consent_document?
    user.verify_permission && !user.archived?
  end

  def update_consent_method?
    user.verify_permission && !user.archived?
  end

  alias_method :edit_consent_method?, :update_consent_method?

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
