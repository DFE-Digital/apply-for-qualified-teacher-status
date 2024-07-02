# frozen_string_literal: true

class AddQualificationsInformationToCountriesAndRegions < ActiveRecord::Migration[
  7.0
]
  def change
    add_column :countries,
               :qualifications_information,
               :text,
               default: "",
               null: false
    add_column :regions,
               :qualifications_information,
               :text,
               default: "",
               null: false
  end
end
