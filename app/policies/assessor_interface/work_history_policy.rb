# frozen_string_literal: true

class AssessorInterface::WorkHistoryPolicy < ApplicationPolicy
  def update?
    user.change_work_history_permission && !user.archived?
  end
end
