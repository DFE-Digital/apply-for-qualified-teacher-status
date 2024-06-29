# frozen_string_literal: true

class RemoveLegacyFromRegion < ActiveRecord::Migration[7.0]
  def change
    remove_column :countries, :legacy, :boolean, null: false, default: false
  end
end
