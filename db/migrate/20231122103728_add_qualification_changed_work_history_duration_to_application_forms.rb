class AddQualificationChangedWorkHistoryDurationToApplicationForms < ActiveRecord::Migration[
  7.1
]
  def change
    add_column :application_forms,
               :qualification_changed_work_history_duration,
               :boolean,
               default: false,
               null: false
  end
end
