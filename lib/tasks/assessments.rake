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

  desc "Migrate preliminary checks"
  task migrate_preliminary_checks: :environment do |_task, _args|
    ApplicationForm
      .not_draft
      .where(requires_preliminary_check: true)
      .each do |application_form|
        assessment = application_form.assessment

        next if assessment.sections.preliminary.exists?

        puts "Migrating: #{application_form.reference}"

        preliminary_section =
          AssessmentFactory.send(:new, application_form:).send(
            :preliminary_qualifications_section,
          )
        preliminary_section.assessment = assessment
        preliminary_section.save!

        # rubocop:disable Rails/SkipsModelValidations
        preliminary_section.update_attribute(
          :passed,
          assessment.preliminary_check_complete,
        )
        # rubocop:enable Rails/SkipsModelValidations
      end
  end
end
