# frozen_string_literal: true

class AddUniqueIndexToSelectedFailureReasonsWorkHistories < ActiveRecord::Migration[
  8.1
]
  disable_ddl_transaction!

  def change
    add_index :selected_failure_reasons_work_histories,
              %i[selected_failure_reason_id work_history_id],
              unique: true,
              algorithm: :concurrently
  end
end
