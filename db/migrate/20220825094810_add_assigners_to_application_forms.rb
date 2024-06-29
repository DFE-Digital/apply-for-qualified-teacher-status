# frozen_string_literal: true

class AddAssignersToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    change_table :application_forms, bulk: true do |t|
      t.references :assessor, foreign_key: { to_table: :staff }
      t.references :reviewer, foreign_key: { to_table: :staff }
    end
  end
end
