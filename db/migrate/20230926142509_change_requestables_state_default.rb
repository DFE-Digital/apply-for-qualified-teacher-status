# frozen_string_literal: true

class ChangeRequestablesStateDefault < ActiveRecord::Migration[7.0]
  def change
    change_column_default :further_information_requests,
                          :state,
                          from: nil,
                          to: "requested"
    change_column_default :professional_standing_requests,
                          :state,
                          from: nil,
                          to: "requested"
    change_column_default :qualification_requests,
                          :state,
                          from: nil,
                          to: "requested"
    change_column_default :reference_requests,
                          :state,
                          from: nil,
                          to: "requested"
  end
end
