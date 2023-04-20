desc "Update application status"
task update_application_form_status_initial_assessment: :environment do
  # fetch all application forms with 'initial assessment' status
  forms = ApplicationForm.where(status: "initial_assessment")

  # update the status for each form
  forms.update_all(state: "assessment_in_progress")
end
