# frozen_string_literal: true

class CreateEnglishLanguageProvider < ActiveRecord::Migration[7.0]
  def change
    create_table :english_language_providers do |t|
      t.string :name, null: false
      t.text :b2_level_requirement, null: false
      t.string :reference_name, null: false
      t.text :reference_hint, null: false
      t.timestamps
    end
  end
end
