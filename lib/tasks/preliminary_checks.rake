namespace :preliminary_checks do
  desc "Apply 'preliminary_check' status to existing submitted applications"
  task update_submitted_applications: :environment do
    ApplicationForm
      .submitted
      .joins(region: :country)
      .where(assessor_id: nil)
      .where(
        "countries.requires_preliminary_check = true OR \
             regions.requires_preliminary_check = true",
      )
      .update_all(status: :preliminary_check)
  end
end
