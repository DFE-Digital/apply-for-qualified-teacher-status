# frozen_string_literal: true

class CreateAssessments < ActiveRecord::Migration[7.0]
  def change
    create_table :assessments do |t|
      t.references :application_form, null: false, foreign_key: true
      t.string :recommendation, null: false, default: "unknown"
      t.timestamps
    end
  end
end
