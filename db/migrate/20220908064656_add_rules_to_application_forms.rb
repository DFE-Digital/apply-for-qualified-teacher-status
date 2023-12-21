class AddRulesToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    change_table :application_forms, bulk: true do |t|
      t.boolean :needs_work_history
      t.boolean :needs_written_statement
      t.boolean :needs_registration_number
    end

    ApplicationForm
      .includes(:region)
      .find_each do |application_form|
        region = application_form.region

        application_form.update!(
          needs_work_history:
            region.status_check_none? || region.sanction_check_none?,
          needs_written_statement:
            region.status_check_online? || region.sanction_check_online?,
          needs_registration_number:
            region.status_check_written? || region.sanction_check_written?,
        )
      end

    change_column_null :application_forms, :needs_work_history, false
    change_column_null :application_forms, :needs_written_statement, false
    change_column_null :application_forms, :needs_registration_number, false
  end
end
