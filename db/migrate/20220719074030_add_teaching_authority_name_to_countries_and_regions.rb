# frozen_string_literal: true

class AddTeachingAuthorityNameToCountriesAndRegions < ActiveRecord::Migration[
  7.0
]
  def change
    add_column :countries,
               :teaching_authority_name,
               :text,
               default: "",
               null: false
    add_column :regions,
               :teaching_authority_name,
               :text,
               default: "",
               null: false
  end
end
