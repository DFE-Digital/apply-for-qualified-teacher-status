class AddHasWorkHistoryToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    add_column :application_forms, :has_work_history, :boolean
  end
end
