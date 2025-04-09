# frozen_string_literal: true

class AssessorInterface::FurtherInformationRequestPolicy < ApplicationPolicy
  def create?
    user.assess_permission && !user.archived?
  end

  def update?
    user.assess_permission && !user.archived?
  end

  def edit?
    return false if user.archived?

    true
  end

  def edit_decline?
    edit?
  end

  def update_decline?
    update?
  end
end
