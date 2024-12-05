# frozen_string_literal: true

class DropColumnForDQTMatch < ActiveRecord::Migration[7.2]
  def change
    remove_column :application_forms, :dqt_match, :jsonb, default: {}
  end
end
