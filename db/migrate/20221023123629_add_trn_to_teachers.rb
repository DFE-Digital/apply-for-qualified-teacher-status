class AddTRNToTeachers < ActiveRecord::Migration[7.0]
  def change
    add_column :teachers, :trn, :string
  end
end
