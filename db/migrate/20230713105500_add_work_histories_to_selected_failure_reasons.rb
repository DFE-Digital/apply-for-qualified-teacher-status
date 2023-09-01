class AddWorkHistoriesToSelectedFailureReasons < ActiveRecord::Migration[7.0]
  def change
    create_join_table "work_histories", "selected_failure_reasons"
    add_reference :further_information_request_items,
                  :work_history,
                  foreign_key: true,
                  null: true
    change_table :further_information_request_items, bulk: true do |t|
      t.column :contact_name, :string
      t.column :contact_job, :string
      t.column :contact_email, :string
    end
  end
end
