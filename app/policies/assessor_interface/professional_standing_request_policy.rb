# frozen_string_literal: true

class AssessorInterface::ProfessionalStandingRequestPolicy < ApplicationPolicy
  def update_location?
    true
  end

  alias_method :edit_location?, :update_location?

  def update_review?
    user.award_decline_permission
  end

  alias_method :edit_review?, :update_review?
end
