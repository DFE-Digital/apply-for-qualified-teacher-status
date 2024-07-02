# frozen_string_literal: true

class CreateFurtherInformationRequestItems < ActiveRecord::Migration[7.0]
  def change
    create_table :further_information_request_items do |t|
      t.references :further_information_request,
                   index: {
                     name: "index_fi_request_items_on_fi_request_id",
                   }
      t.text :assessor_notes
      t.string :information_type
      t.text :response
      t.timestamps
    end
  end
end
