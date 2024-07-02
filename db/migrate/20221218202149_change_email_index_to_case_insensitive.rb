# frozen_string_literal: true

class ChangeEmailIndexToCaseInsensitive < ActiveRecord::Migration[7.0]
  def change
    remove_index :staff, :email, unique: true
    remove_index :teachers, :email, unique: true

    add_index :staff,
              "LOWER(email)",
              name: "index_staff_on_lower_email",
              unique: true
    add_index :teachers,
              "LOWER(email)",
              name: "index_teacher_on_lower_email",
              unique: true
  end
end
