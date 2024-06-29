# frozen_string_literal: true

class AddResponsesToReferenceRequests < ActiveRecord::Migration[7.0]
  def change
    change_table :reference_requests, bulk: true do |t|
      t.boolean :contact_response
      t.string :contact_name, default: "", null: false
      t.string :contact_job, default: "", null: false
      t.text :contact_comment, default: "", null: false

      t.text :dates_comment, default: "", null: false
      t.text :hours_comment, default: "", null: false
      t.text :children_comment, default: "", null: false
      t.text :lessons_comment, default: "", null: false
      t.text :reports_comment, default: "", null: false

      t.boolean :misconduct_response
      t.text :misconduct_comment, default: "", null: false

      t.boolean :satisfied_response
      t.text :satisfied_comment, default: "", null: false
    end
  end
end
