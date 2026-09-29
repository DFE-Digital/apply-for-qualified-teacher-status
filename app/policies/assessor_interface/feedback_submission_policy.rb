# frozen_string_literal: true

class AssessorInterface::FeedbackSubmissionPolicy < ApplicationPolicy
  def index?
    user.support_console_permission? && !user.archived?
  end

  alias_method :show?, :index?
  alias_method :apply_filters?, :index?
  alias_method :clear_filters?, :index?
end
