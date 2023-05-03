desc "Update initial assessment timeline events"
task update_initial_assessment_timeline_events: :environment do
  # fetch all timeline events with 'initial assessment' status
  oldstates = TimelineEvent.where(old_state: "initial_assessment")
  newstates = TimelineEvent.where(new_state: "initial_assessment")

  # update the status for each event
  oldstates.update_all(old_state: "assessment_in_progress")
  newstates.update_all(new_state: "assessment_in_progress")
end
