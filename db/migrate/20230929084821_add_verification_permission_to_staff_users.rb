class AddVerificationPermissionToStaffUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :staff, :verify_permission, :boolean, default: false, null: false
  end
end
