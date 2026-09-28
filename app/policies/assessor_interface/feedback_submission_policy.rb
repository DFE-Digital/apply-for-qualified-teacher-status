# frozen_string_literal: true

class AssessorInterface::FeedbackSubmissionPolicy < ApplicationPolicy
  def index?
    return false if user.archived?

    true
  end

  alias_method :show?, :index?
  alias_method :apply_filters?, :index?
  alias_method :clear_filters?, :index?
end
