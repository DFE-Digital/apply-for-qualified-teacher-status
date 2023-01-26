namespace :timeline_events do
  desc "Migrate the old further information requests event type."
  task migrate_further_information_requests: :environment do
    TimelineEvent.further_information_request_expired.each do |timeline_event|
      timeline_event.update!(
        event_type: "requestable_expired",
        requestable: timeline_event.further_information_request,
        further_information_request: nil,
      )
    end

    TimelineEvent.further_information_request_assessed.each do |timeline_event|
      timeline_event.update!(
        event_type: "requestable_assessed",
        requestable: timeline_event.further_information_request,
        further_information_request: nil,
      )
    end
  end
end
