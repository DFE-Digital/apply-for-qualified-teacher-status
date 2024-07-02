# frozen_string_literal: true

class AddFailureReasonToFurtherInformationRequestItem < ActiveRecord::Migration[
  7.0
]
  def change
    add_column :further_information_request_items,
               :failure_reason,
               :string,
               null: false,
               default: ""
  end
end
