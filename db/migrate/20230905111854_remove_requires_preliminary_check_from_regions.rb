class RemoveRequiresPreliminaryCheckFromRegions < ActiveRecord::Migration[7.0]
  def change
    remove_column :regions,
                  :requires_preliminary_check,
                  :boolean,
                  default: false,
                  null: false
  end
end
