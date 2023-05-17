namespace :quick_decline do
  desc "Backfill case notes for quick decline applications"
  task backfill_case_notes: :environment do
    scope =
      ApplicationForm
        .joins(assessment: :sections)
        .where(
          status: "declined",
          requires_preliminary_check: true,
          assessment: {
            preliminary_check_complete: false,
          },
          sections: {
            passed: nil,
          },
        )
        .distinct

    scope.find_each do |application_form|
      if TimelineEvent.exists?(application_form:, event_type: "quick_decline")
        next
      end

      CreateQuickDeclineTimelineEvent.call(application_form:)
    end
  end
end
