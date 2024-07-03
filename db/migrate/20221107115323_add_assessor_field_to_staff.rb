# frozen_string_literal: true

class AddAssessorFieldToStaff < ActiveRecord::Migration[7.0]
  def change
    add_column :staff, :assessor, :boolean, default: false, nullable: false
  end
end
