# frozen_string_literal: true

class RemoveStateFromRequestables < ActiveRecord::Migration[7.0]
  def change
    remove_column :further_information_requests,
                  :state,
                  :string,
                  null: false,
                  default: "requested"
    remove_column :professional_standing_requests,
                  :state,
                  :string,
                  null: false,
                  default: "requested"
    remove_column :qualification_requests,
                  :state,
                  :string,
                  null: false,
                  default: "requested"
    remove_column :reference_requests,
                  :state,
                  :string,
                  null: false,
                  default: "requested"
  end
end
