# frozen_string_literal: true

class AddPrioritisationWorkHistoryCheckToSelectedFailureReasons < ActiveRecord::Migration[
  8.0
]
  def up
    add_reference :selected_failure_reasons,
                  :prioritisation_work_history_check,
                  index: {
                    name:
                      "index_as_failure_reason_prioritisation_work_history_check_id",
                  },
                  foreign_key: true
    change_column_null :selected_failure_reasons, :assessment_section_id, true
  end

  def down
    remove_reference :selected_failure_reasons,
                     :prioritisation_work_history_check
    change_column_null :selected_failure_reasons, :assessment_section_id, false
  end
end
