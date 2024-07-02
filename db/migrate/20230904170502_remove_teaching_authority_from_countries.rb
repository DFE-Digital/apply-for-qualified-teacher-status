# frozen_string_literal: true

class RemoveTeachingAuthorityFromCountries < ActiveRecord::Migration[7.0]
  def change
    change_table :countries, bulk: true do |t|
      t.remove :teaching_authority_address,
               type: :text,
               default: "",
               null: false
      t.remove :teaching_authority_certificate,
               type: :text,
               default: "",
               null: false
      t.remove :teaching_authority_emails,
               type: :text,
               default: [],
               null: false,
               array: true
      t.remove :teaching_authority_name, type: :text, default: "", null: false
      t.remove :teaching_authority_online_checker_url,
               type: :string,
               default: "",
               null: false
      t.remove :teaching_authority_websites,
               type: :text,
               default: [],
               null: false,
               array: true
    end
  end
end
