# frozen_string_literal: true

class AssessorInterface::EmailDeliveryPolicy < ApplicationPolicy
  def index?
    return false if user.archived?

    true
  end
end
