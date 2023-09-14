class AddStageToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    add_column :application_forms,
               :stage,
               :string,
               default: "draft",
               null: false
    add_index :application_forms, :stage
  end
end
