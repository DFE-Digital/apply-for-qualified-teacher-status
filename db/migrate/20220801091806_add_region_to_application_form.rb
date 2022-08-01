class AddRegionToApplicationForm < ActiveRecord::Migration[7.0]
  def up
    add_reference :application_forms, :region, foreign_key: true, null: true

    ApplicationForm
      .includes(:eligibility_check)
      .find_each do |application_form|
        application_form.update!(
          region_id: application_form.eligibility_check.region.id
        )
      end

    change_column_null :application_forms, :region_id, false
  end

  def down
    remove_reference :application_forms, :region
  end
end
