# frozen_string_literal: true

class AddTeachingAuthorityStatusSanctionInformation < ActiveRecord::Migration[
  7.0
]
  def change
    change_table(:countries, bulk: true) do |t|
      t.string :teaching_authority_status_information, default: "", null: false
      t.string :teaching_authority_sanction_information,
               default: "",
               null: false
    end

    change_table(:regions, bulk: true) do |t|
      t.string :teaching_authority_status_information, default: "", null: false
      t.string :teaching_authority_sanction_information,
               default: "",
               null: false
    end
  end
end
