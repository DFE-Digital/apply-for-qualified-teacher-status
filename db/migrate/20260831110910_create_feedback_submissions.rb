# frozen_string_literal: true

class CreateFeedbackSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :feedback_submissions do |t|
      t.string :application_status
      t.string :overall_experience
      t.text :comment
      t.datetime :submitted_at

      t.timestamps
    end
  end
end
