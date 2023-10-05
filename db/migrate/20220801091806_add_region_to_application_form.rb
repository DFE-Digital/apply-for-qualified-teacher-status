class AddRegionToApplicationForm < ActiveRecord::Migration[7.0]
  def up
    add_reference :application_forms, :region, foreign_key: true, null: true
    change_column_null :application_forms, :region_id, false
  end

  def down
    remove_reference :application_forms, :region
  end
end
