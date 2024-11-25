# frozen_string_literal: true

class AddSchoolAddressDetailsToWorkHistory < ActiveRecord::Migration[7.2]
  def change
    change_table :work_histories, bulk: true do |t|
      t.column :address_line1, :string
      t.column :address_line2, :string
      t.column :school_website, :string
    end
  end
end
