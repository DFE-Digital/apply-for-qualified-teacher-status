# frozen_string_literal: true

module AssessorInterface
  class PrioritisationWorkHistoryCheckViewObject
    def initialize(prioritisation_work_history_check:)
      @prioritisation_work_history_check = prioritisation_work_history_check
    end

    delegate :assessment,
             :work_history,
             :checks,
             to: :prioritisation_work_history_check
    delegate :application_form, to: :assessment

    attr_reader :prioritisation_work_history_check

    def disable_form?
      # TODO: Once the prioritisation reference requests have been made, form will be disabled.
      false
    end
  end
end
