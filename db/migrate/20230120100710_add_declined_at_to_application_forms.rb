# frozen_string_literal: true

class AddDeclinedAtToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    add_column :application_forms, :declined_at, :datetime
  end
end
