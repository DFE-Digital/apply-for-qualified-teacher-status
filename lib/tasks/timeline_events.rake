namespace :timeline_events do
  desc "Migrate the old further information request expired event type."
  task migrate_further_information_request_expired: :environment do
    TimelineEvent.further_information_request_expired.each do |timeline_event|
      timeline_event.update!(
        event_type: "requestable_expired",
        requestable: timeline_event.further_information_request,
        further_information_request: nil,
      )
    end
  end
end
