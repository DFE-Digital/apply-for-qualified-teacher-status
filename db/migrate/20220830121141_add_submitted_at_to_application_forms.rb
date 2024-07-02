# frozen_string_literal: true

class AddSubmittedAtToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    add_column :application_forms, :submitted_at, :datetime
  end
end
