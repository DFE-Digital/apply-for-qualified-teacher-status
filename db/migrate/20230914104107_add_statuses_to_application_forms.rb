class AddStatusesToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    add_column :application_forms,
               :statuses,
               :string,
               default: %w[draft],
               array: true,
               null: false
  end
end
