namespace :timeline_events do
  desc "Migrate old_state/new_state"
  task migrate_old_new_state: :environment do
    TimelineEvent
      .where(event_type: %w[status_changed assessment_section_recorded])
      .each do |timeline_event|
        timeline_event.update!(
          old_value: timeline_event.old_state,
          new_value: timeline_event.new_state,
          old_state: "",
          new_state: "",
        )
      end
  end
end
