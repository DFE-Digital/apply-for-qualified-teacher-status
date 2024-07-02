# frozen_string_literal: true

class AddTeachingAuthorityToCountries < ActiveRecord::Migration[7.0]
  def change
    change_table :countries, bulk: true do |t|
      t.column :teaching_authority_address, :text, default: "", null: false
      t.column :teaching_authority_emails,
               :text,
               default: [],
               null: false,
               array: true
      t.column :teaching_authority_websites,
               :text,
               default: [],
               null: false,
               array: true
    end
  end
end
