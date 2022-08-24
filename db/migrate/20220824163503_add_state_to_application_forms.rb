class AddStateToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    add_column :application_forms, :state, :string
  end
end
