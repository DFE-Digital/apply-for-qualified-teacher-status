# frozen_string_literal: true

class AddRequiresPreliminaryCheckToRegions < ActiveRecord::Migration[7.0]
  def change
    add_column :regions,
               :requires_preliminary_check,
               :boolean,
               null: false,
               default: false
  end
end
