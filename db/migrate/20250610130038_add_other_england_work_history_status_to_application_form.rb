# frozen_string_literal: true

class AddOtherEnglandWorkHistoryStatusToApplicationForm < ActiveRecord::Migration[
  8.0
]
  def change
    change_table :application_forms, bulk: true do |t|
      t.boolean :has_other_england_work_history
      t.string :other_england_work_history_status,
               default: "not_started",
               null: false
    end
  end
end
