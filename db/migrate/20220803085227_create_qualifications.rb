# frozen_string_literal: true

class CreateQualifications < ActiveRecord::Migration[7.0]
  def change
    create_table :qualifications do |t|
      t.references :application_form, null: false, foreign_key: true
      t.text :title, default: "", null: false
      t.text :institution_name, default: "", null: false
      t.text :institution_country, default: "", null: false
      t.date :start_date
      t.date :complete_date
      t.date :certificate_date
      t.timestamps
    end
  end
end
