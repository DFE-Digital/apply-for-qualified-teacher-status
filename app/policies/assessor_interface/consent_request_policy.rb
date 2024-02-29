# frozen_string_literal: true

class AssessorInterface::ConsentRequestPolicy < ApplicationPolicy
  def update_review?
    user.assess_permission
  end

  alias_method :edit_review?, :update_review?
end
