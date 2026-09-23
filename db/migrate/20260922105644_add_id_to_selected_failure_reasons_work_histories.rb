# frozen_string_literal: true

class AddIdToSelectedFailureReasonsWorkHistories < ActiveRecord::Migration[8.1]
  def change
    add_column :selected_failure_reasons_work_histories, :id, :primary_key
  end
end
