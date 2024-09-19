class AddArchivedToStaff < ActiveRecord::Migration[7.2]
  def change
    add_column :staff, :archived, :boolean, default: false
  end
end
