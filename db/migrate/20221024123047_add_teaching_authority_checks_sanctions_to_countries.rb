# frozen_string_literal: true

class AddTeachingAuthorityChecksSanctionsToCountries < ActiveRecord::Migration[
  7.0
]
  def change
    add_column :countries,
               :teaching_authority_checks_sanctions,
               :boolean,
               null: false,
               default: true
  end
end
