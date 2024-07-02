# frozen_string_literal: true

class AddOauthAttributesToStaff < ActiveRecord::Migration[7.0]
  def change
    change_table :staff, bulk: true do |t|
      t.string :azure_ad_uid
    end
  end
end
