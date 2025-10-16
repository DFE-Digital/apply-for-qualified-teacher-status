# frozen_string_literal: true

module AssessorInterface
  class PrioritisationWorkHistoryCheckViewObject
    def initialize(prioritisation_work_history_check:)
      @prioritisation_work_history_check = prioritisation_work_history_check
    end

    delegate :assessment,
             :work_history,
             :checks,
             :failure_reasons,
             :selected_failure_reasons,
             to: :prioritisation_work_history_check
    delegate :application_form, to: :assessment
    delegate :on_hold?, to: :application_form

    attr_reader :prioritisation_work_history_check

    def disable_form?
      return true if on_hold?

      assessment.prioritisation_reference_requests.present? ||
        assessment.prioritisation_decision_at.present?
    end
  end
end
