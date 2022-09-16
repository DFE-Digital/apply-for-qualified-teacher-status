module TimelineEntry
  class Component < ViewComponent::Base
    def initialize(timeline_event:)
      super
      @timeline_event = timeline_event
    end

    attr_reader :timeline_event

    def description_vars
      send("#{timeline_event.event_type}_vars")
    end

    private

    def state_changed_vars
      {
        old_state:
          render(
            ApplicationFormStatusTag::Component.new(
              key: timeline_event.id,
              status: timeline_event.old_state,
              class_context: "timeline-event"
            )
          ),
        new_state:
          render(
            ApplicationFormStatusTag::Component.new(
              key: timeline_event.id,
              status: timeline_event.new_state,
              class_context: "timeline-event"
            )
          )
      }
    end

    def assessor_assigned_vars
      { assignee_name: timeline_event.assignee.name }
    end

    alias_method :reviewer_assigned_vars, :assessor_assigned_vars

    def assessment_section_recorded_vars
      section = timeline_event.eventable
      {
        section_name: section.key.titleize,
        section_state:
          render(
            ApplicationFormStatusTag::Component.new(
              key: timeline_event.id,
              status: section.state,
              class_context: "timeline-event"
            )
          )
      }
    end
  end
end
