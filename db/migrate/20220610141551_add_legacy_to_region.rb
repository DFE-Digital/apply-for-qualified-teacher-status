# frozen_string_literal: true

class AddLegacyToRegion < ActiveRecord::Migration[7.0]
  def change
    add_column :regions, :legacy, :boolean, null: false, default: true
  end
end
