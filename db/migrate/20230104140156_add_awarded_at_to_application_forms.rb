class AddAwardedAtToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    add_column :application_forms, :awarded_at, :datetime
  end
end
