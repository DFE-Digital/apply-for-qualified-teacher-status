# frozen_string_literal: true

class AddContactNameToWorkHistory < ActiveRecord::Migration[7.0]
  def change
    change_table :work_histories, bulk: true do |t|
      t.column :contact_name, :text, null: false, default: ""
      t.rename :email, :contact_email
    end
  end
end
