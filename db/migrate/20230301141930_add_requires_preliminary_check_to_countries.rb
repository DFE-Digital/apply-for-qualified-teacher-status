# frozen_string_literal: true

class AddRequiresPreliminaryCheckToCountries < ActiveRecord::Migration[7.0]
  def change
    add_column :countries,
               :requires_preliminary_check,
               :boolean,
               null: false,
               default: false
  end
end
