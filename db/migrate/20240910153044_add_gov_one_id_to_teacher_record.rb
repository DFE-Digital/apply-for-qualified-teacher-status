# frozen_string_literal: true

class AddGovOneIdToTeacherRecord < ActiveRecord::Migration[7.2]
  def change
    add_column :teachers, :gov_one_id, :string
    add_index :teachers, :gov_one_id, unique: true
  end
end
