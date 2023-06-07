class AddOauthAttributesToStaff < ActiveRecord::Migration[7.0]
  def change
    change_table :staff, bulk: true do |t|
      t.string :provider
      t.string :uid
    end
  end
end
