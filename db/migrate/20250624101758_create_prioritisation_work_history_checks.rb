# frozen_string_literal: true

class CreatePrioritisationWorkHistoryChecks < ActiveRecord::Migration[8.0]
  def change
    create_table :prioritisation_work_history_checks do |t|
      t.references :assessment, null: false, foreign_key: true
      t.references :work_history, null: false, foreign_key: true

      t.boolean :passed

      t.string :checks, array: true, default: []
      t.string :failure_reasons, array: true, default: []

      t.timestamps
    end
  end
end
