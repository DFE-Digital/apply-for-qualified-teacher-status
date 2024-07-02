# frozen_string_literal: true

class AddTeachingAuthorityOnlineCheckerUrlToCountriesAndRegions < ActiveRecord::Migration[
  7.0
]
  def change
    add_column :countries,
               :teaching_authority_online_checker_url,
               :string,
               default: "",
               null: false

    add_column :regions,
               :teaching_authority_online_checker_url,
               :string,
               default: "",
               null: false
  end
end
