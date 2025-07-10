# frozen_string_literal: true

class CreateSelectedPrioritisationFailureReasons < ActiveRecord::Migration[8.0]
  def change
    create_table :selected_prioritisation_failure_reasons do |t|
      t.references :prioritisation_work_history_check,
                   null: false,
                   foreign_key: true,
                   index: {
                     name:
                       "index_as_prioritisation_failure_reason_work_history_check_id",
                   }

      t.string :key, null: false
      t.text :assessor_feedback

      t.timestamps
    end
  end
end
