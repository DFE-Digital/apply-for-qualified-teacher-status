namespace :assessments do
  desc "Rollback an assessment from an award or decline recommendation."
  task :rollback, %i[reference staff_email] => :environment do |_task, args|
    assessment =
      Assessment.joins(:application_form).find_by!(
        application_forms: {
          reference: args[:reference],
        },
      )

    user = Staff.find_by!(email: args[:staff_email])

    RollbackAssessment.call(assessment:, user:)
  end
end
