# frozen_string_literal: true

class DeviseCreateTeachers < ActiveRecord::Migration[7.0]
  def change
    create_table :teachers do |t|
      t.string :email, null: false, default: ""

      t.timestamps null: false
    end

    add_index :teachers, :email, unique: true
  end
end
