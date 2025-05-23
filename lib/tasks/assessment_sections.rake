# frozen_string_literal: true

namespace :assessment_sections do
  desc "Edit failure reasons on an assessment section. \
  eg. edit_failure_reasons['work_history', 'new_reason', 'existing_reason1 existing_reason2']"
  task :edit_failure_reasons,
       %i[key new_failure_reason failure_reasons] =>
         :environment do |_task, args|
    key = args[:key]
    new_failure_reason = args[:new_failure_reason]
    failure_reasons = args[:failure_reasons].split(" ")

    scope = AssessmentSection.where(key:, failure_reasons:)

    if scope.count.zero?
      raise "No assessment sections found for key: #{key}, failure_reasons: #{failure_reasons}"
    end

    puts "#{scope.count} assessment sections match"

    if failure_reasons.include?(new_failure_reason)
      failure_reasons.delete(new_failure_reason)
    else
      failure_reasons << new_failure_reason
    end

    scope.update_all(failure_reasons:)

    puts "Assessment sections with key #{key} updated with failure reasons: #{failure_reasons}"
  end

  desc "Sync assessments not started with latest version of checks and failure reasons"
  task sync_not_started_assessments_checks_and_failure_reasons: :environment do
    assessments_not_started =
      Assessment.includes(:application_form).where(
        application_form: {
          stage: %w[not_started pre_assessment],
        },
      )

    assessments_not_started.find_each do |assessment|
      SyncAssessmentChecksAndFailureReasonsJob.perform_later(assessment)
    end
  end
end
