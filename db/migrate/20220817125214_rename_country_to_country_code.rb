# frozen_string_literal: true

class RenameCountryToCountryCode < ActiveRecord::Migration[7.0]
  def change
    rename_column :qualifications,
                  :institution_country,
                  :institution_country_code
    rename_column :work_histories, :country, :country_code
  end
end
