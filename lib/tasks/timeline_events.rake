namespace :timeline_events do
  desc "Migrate state_changed events"
  task migrate_state_changed: :environment do
    TimelineEvent.where(event_type: "state_changed").update_all(
      event_type: "status_changed",
    )
  end
end
