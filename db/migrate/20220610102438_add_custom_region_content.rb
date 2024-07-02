# frozen_string_literal: true

class AddCustomRegionContent < ActiveRecord::Migration[7.0]
  def change
    change_table :regions, bulk: true do |t|
      t.column :status_check, :string, default: "none", null: false
      t.column :sanction_check, :string, default: "none", null: false
      t.column :teaching_authority_certificate, :text, default: "", null: false
      t.column :teaching_authority_address, :text, default: "", null: false
      t.column :teaching_authority_website, :text, default: "", null: false
      t.column :teaching_authority_email_address,
               :text,
               default: "",
               null: false
    end
  end
end
