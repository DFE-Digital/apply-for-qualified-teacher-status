# frozen_string_literal: true

class CreateFeedbackSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :feedback_submissions do |t|
      t.references :teacher, null: true, foreign_key: true
      t.references :application_form, null: true, foreign_key: true
      t.string :application_status, null: false
      t.string :overall_experience, null: false
      t.text :comment

      t.timestamps
    end
  end
end
