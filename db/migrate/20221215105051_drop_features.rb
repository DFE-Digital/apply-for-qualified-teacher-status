# frozen_string_literal: true

class DropFeatures < ActiveRecord::Migration[7.0]
  def up
    drop_table :features
  end
end
