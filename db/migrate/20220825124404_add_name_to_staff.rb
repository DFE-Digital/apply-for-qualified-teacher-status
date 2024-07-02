# frozen_string_literal: true

class AddNameToStaff < ActiveRecord::Migration[7.0]
  def change
    add_column :staff, :name, :text, null: false, default: ""
  end
end
