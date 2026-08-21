# frozen_string_literal: true

class AssessorInterface::ServiceLevelAgreementPolicy < ApplicationPolicy
  def index?
    return false if user.archived?

    true
  end

  alias_method :apply_filters?, :index?
  alias_method :clear_filters?, :index?
  alias_method :totals?, :index?
end
