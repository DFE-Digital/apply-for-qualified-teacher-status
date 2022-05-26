class AddEligibleContentToCountry < ActiveRecord::Migration[7.0]
  def change
    add_column :countries, :eligible_content, :text, null: false, default: ""
  end
end
