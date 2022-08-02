class AddRegionToApplicationForm < ActiveRecord::Migration[7.0]
  def up
    add_reference :application_forms, :region, foreign_key: true, null: true

    ApplicationForm.find_each do |application_form|
      eligibility_check =
        EligibilityCheck.find(application_form.eligibility_check_id)
      application_form.update!(region_id: eligibility_check.region_id)
    end

    change_column_null :application_forms, :region_id, false
  end

  def down
    remove_reference :application_forms, :region
  end
end
