# frozen_string_literal: true

class RemoveTeachingAuthoritySingles < ActiveRecord::Migration[7.0]
  def up
    change_table :regions, bulk: true do |t|
      t.remove :teaching_authority_website, :teaching_authority_email_address
    end
  end

  def down
    change_table :regions, bulk: true do |t|
      t.column :teaching_authority_website, :text, default: "", null: false
      t.column :teaching_authority_email_address,
               :text,
               default: "",
               null: false
    end
  end
end
