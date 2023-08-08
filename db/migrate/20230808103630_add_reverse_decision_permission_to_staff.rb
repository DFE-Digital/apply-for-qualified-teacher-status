class AddReverseDecisionPermissionToStaff < ActiveRecord::Migration[7.0]
  def change
    add_column :staff,
               :reverse_decision_permission,
               :boolean,
               default: false,
               null: false
  end
end
