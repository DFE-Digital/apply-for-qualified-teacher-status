# frozen_string_literal: true

class AssessorInterface::QualificationRequestPolicy < ApplicationPolicy
  def index?
    true
  end

  def index_consent_methods?
    user.verify_permission
  end

  def consent_letter?
    user.verify_permission
  end

  def update?
    user.verify_permission
  end

  def update_consent_method?
    user.verify_permission
  end

  alias_method :edit_consent_method?, :update_consent_method?

  def update_review?
    user.assess_permission
  end

  alias_method :edit_review?, :update_review?
end
