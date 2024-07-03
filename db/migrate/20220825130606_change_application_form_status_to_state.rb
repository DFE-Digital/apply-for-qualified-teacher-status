# frozen_string_literal: true

class ChangeApplicationFormStatusToState < ActiveRecord::Migration[7.0]
  def change
    change_table :application_forms, bulk: true do |t|
      t.string :state, null: false, default: "draft"
      t.remove :status, type: :string, null: false, default: "active"
      t.index :state
    end
  end
end
