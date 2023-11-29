namespace :application_forms do
  desc "Delete all draft application forms."
  task delete_drafts: :environment do
    puts "This task is destructive! Are you sure you want to continue?"
    $stdin.gets.chomp

    original_count = ApplicationForm.count

    ApplicationForm.draft.each do |application_form|
      DestroyApplicationForm.call(application_form:)
    end

    new_count = ApplicationForm.count

    puts "There were #{original_count} draft applications and there are now #{new_count}."
    puts "There are #{ApplicationForm.count} applications overall."
  end

  desc "Backfill preliminary checks on applications after enabling them."
  task :backfill_preliminary_checks,
       %i[staff_email] => :environment do |_task, args|
    user = Staff.find_by!(email: args[:staff_email])
    count = BackfillPreliminaryChecks.call(user:)
    puts "Updated #{count} applications."
  end

  desc "Update the statuses of all application forms."
  task :update_statuses, %i[staff_email] => :environment do |_task, args|
    user = Staff.find_by!(email: args[:staff_email])
    ApplicationForm
      .order(:id)
      .find_each do |application_form|
        ApplicationFormStatusUpdater.call(application_form:, user:)
        puts "#{application_form.reference}: #{application_form.action_required_by} - #{application_form.status}"
      end
  end

  desc "Decline applications with less than 9 months of work experience."
  task :decline_work_history_duration,
       %i[staff_email] => :environment do |_task, args|
    user = Staff.find_by!(email: args[:staff_email])
    zimbabwe = Country.find_by!(code: "ZW").regions.first

    ApplicationForm
      .not_started_stage
      .where.not(region: zimbabwe)
      .where(needs_work_history: true)
      .each do |application_form|
        if WorkHistoryDuration.for_application_form(
             application_form,
             consider_teaching_qualification: true,
           ).enough_for_submission?
          next
        end

        assessment = application_form.assessment

        assessment_section = assessment.sections.find_by!(key: "work_history")
        assessment_section.selected_failure_reasons.create!(
          key: FailureReasons::WORK_HISTORY_DURATION,
          assessor_feedback:
            "You have added at least one teaching role that started before you " \
              "were recognised as a teacher.\n\nWe do not accept teaching work " \
              "experience that was gained before you were recognised as a " \
              "teacher.\n\nThis means you have less than 9 months eligible teaching " \
              "work history and are not eligible for QTS.\n\nYou can reapply for " \
              "QTS once you have gained more teaching work experience. If you have " \
              "this experience already, you can reapply and provide evidence of " \
              "this as part of your new application.",
        )

        application_form.reload

        DeclineQTS.call(application_form:, user:)

        puts application_form.reference
      end
  end
end
