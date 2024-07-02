# frozen_string_literal: true

require "rspec/expectations"

RSpec::Matchers.define :have_recorded_timeline_event do |event_type, **attributes|
  timeline_events = TimelineEvent.where(event_type:).order(:created_at)

  match do |actual|
    expect { actual.call }.to change(timeline_events, :count).by_at_least(1)

    timeline_event = timeline_events.last

    attributes.each do |key, value|
      expect(timeline_event.send(key)).to eq(value)
    end
  end

  match_when_negated do |actual|
    expect { actual.call }.not_to change(timeline_events, :count)
  end

  supports_block_expectations
end
