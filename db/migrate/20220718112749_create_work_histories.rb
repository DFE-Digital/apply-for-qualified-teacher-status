# frozen_string_literal: true

class CreateWorkHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :work_histories do |t|
      t.references :application_form, null: false, foreign_key: true
      t.text :school_name, default: "", null: false
      t.text :city, default: "", null: false
      t.text :country, default: "", null: false
      t.text :job, default: "", null: false
      t.text :email, default: "", null: false
      t.date :start_date
      t.boolean :still_employed
      t.date :end_date
      t.timestamps
    end
  end
end
