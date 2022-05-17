class AddRecognisedToEligibilityCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :eligibility_checks, :recognised, :boolean
  end
end
