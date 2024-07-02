# frozen_string_literal: true

class AddTeachChildrenToEligibilityCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :eligibility_checks, :teach_children, :boolean
  end
end
