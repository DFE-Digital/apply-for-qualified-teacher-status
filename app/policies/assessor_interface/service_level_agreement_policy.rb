# frozen_string_literal: true

class AssessorInterface::ServiceLevelAgreementPolicy < ApplicationPolicy
  def index?
    return false if user.archived?

    true
  end
end
