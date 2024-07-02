# frozen_string_literal: true

class AddNewRegulationFieldsToWorkHistories < ActiveRecord::Migration[7.0]
  def change
    change_table :work_histories, bulk: true do |t|
      t.integer :hours_per_week
      t.boolean :start_date_is_estimate, default: false, null: false
      t.boolean :end_date_is_estimate, default: false, null: false
      t.string :contact_job, default: "", null: false
    end
  end
end
