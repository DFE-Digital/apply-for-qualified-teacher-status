# frozen_string_literal: true

class AssessorInterface::QualificationPolicy < ApplicationPolicy
  def update?
    user.change_work_history_and_qualification_permission && !user.archived?
  end

  def edit_assign_teaching?
    user.change_work_history_and_qualification_permission && !user.archived?
  end

  def update_assign_teaching?
    user.change_work_history_and_qualification_permission && !user.archived?
  end

  def invalid_country?
    user.change_work_history_and_qualification_permission && !user.archived?
  end

  def invalid_work_duration?
    user.change_work_history_and_qualification_permission && !user.archived?
  end
end
