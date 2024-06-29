# frozen_string_literal: true

class AddDQTMatchToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    add_column :application_forms, :dqt_match, :jsonb, default: {}
  end
end
