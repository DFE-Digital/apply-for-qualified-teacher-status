# frozen_string_literal: true

class RemoveTeachingAuthorityChecksSanctionsFromCountries < ActiveRecord::Migration[
  7.0
]
  def change
    remove_column :countries,
                  :teaching_authority_checks_sanctions,
                  :boolean,
                  null: false,
                  default: true
  end
end
