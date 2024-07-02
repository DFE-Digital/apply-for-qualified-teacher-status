# frozen_string_literal: true

class RemoveRequiresPreliminaryCheckFromCountries < ActiveRecord::Migration[7.0]
  def change
    remove_column :countries,
                  :requires_preliminary_check,
                  :boolean,
                  default: false,
                  null: false
  end
end
