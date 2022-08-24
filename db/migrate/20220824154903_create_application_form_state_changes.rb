class CreateApplicationFormStateChanges < ActiveRecord::Migration[7.0]
  def change
    create_table :application_form_state_changes do |t|
      t.string :state, null: false
      t.references :application_form, null: false, foreign_key: true
      t.timestamps
    end

    add_index :application_form_state_changes, :state
  end
end
