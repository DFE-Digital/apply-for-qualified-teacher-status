# frozen_string_literal: true

class Filters::Status < Filters::Base
  def apply
    return scope if statuses.empty?

    exact_statuses = statuses - BOOLEAN_STATUSES
    boolean_statuses = statuses - exact_statuses

    scope.merge(
      boolean_statuses.reduce(
        ApplicationForm.where(status: exact_statuses),
      ) do |status_scope, boolean_status|
        status_scope.or(ApplicationForm.where(boolean_status => true))
      end,
    )
  end

  private

  BOOLEAN_STATUSES = %w[
    overdue_further_information
    overdue_professional_standing
    overdue_qualification
    overdue_reference
    received_further_information
    received_professional_standing
    received_qualification
    received_reference
    waiting_on_further_information
    waiting_on_professional_standing
    waiting_on_qualification
    waiting_on_reference
  ].freeze

  def statuses
    Array(params[:statuses]).reject(&:blank?)
  end
end
