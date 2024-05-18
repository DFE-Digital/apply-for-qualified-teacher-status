class AddRulesToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    change_table :application_forms, bulk: true do |t|
      # rubocop:disable Rails/NotNullColumn
      t.boolean :needs_work_history, null: false
      t.boolean :needs_written_statement, null: false
      t.boolean :needs_registration_number, null: false
      # rubocop:enable Rails/NotNullColumn
    end
  end
end
