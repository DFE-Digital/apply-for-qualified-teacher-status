# frozen_string_literal: true

class Filters::Status < Filters::Base
  def apply
    return scope if statuses.empty?

    exact_statuses = statuses - BOOLEAN_TO_EXACT_STATUSES.keys
    boolean_statuses = statuses - exact_statuses

    scope.merge(
      boolean_statuses.reduce(
        ApplicationForm.where(status: exact_statuses),
      ) do |accumulator, boolean_status|
        accumulator.or(
          ApplicationForm.where(
            {
              boolean_status => true,
              :status => BOOLEAN_TO_EXACT_STATUSES.fetch(boolean_status),
            },
          ),
        )
      end,
    )
  end

  private

  BOOLEAN_TO_EXACT_STATUSES = {
    "overdue_further_information" => "overdue",
    "overdue_professional_standing" => "overdue",
    "overdue_qualification" => "overdue",
    "overdue_reference" => "overdue",
    "received_further_information" => "received",
    "received_professional_standing" => "received",
    "received_qualification" => "received",
    "received_reference" => "received",
    "waiting_on_further_information" => "waiting_on",
    "waiting_on_professional_standing" => "waiting_on",
    "waiting_on_qualification" => "waiting_on",
    "waiting_on_reference" => "waiting_on",
  }.freeze

  def statuses
    Array(params[:statuses]).reject(&:blank?)
  end
end
