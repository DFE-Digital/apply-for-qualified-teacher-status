# frozen_string_literal: true

class AssessorInterface::QualificationRequestPolicy < ApplicationPolicy
  def index?
    true
  end

  def consent_letter?
    user.verify_permission
  end

  def update?
    user.assess_permission
  end

  def update_review?
    user.assess_permission
  end

  alias_method :edit_review?, :update_review?
end
