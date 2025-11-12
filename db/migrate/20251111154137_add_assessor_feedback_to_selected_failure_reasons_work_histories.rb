# frozen_string_literal: true

class AddAssessorFeedbackToSelectedFailureReasonsWorkHistories < ActiveRecord::Migration[
  8.0
]
  def change
    add_column :selected_failure_reasons_work_histories,
               :assessor_feedback,
               :text
  end
end
