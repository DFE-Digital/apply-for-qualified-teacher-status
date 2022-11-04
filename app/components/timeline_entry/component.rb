module TimelineEntry
  class Component < ViewComponent::Base
    def initialize(timeline_event:)
      super
      @timeline_event = timeline_event
    end

    attr_reader :timeline_event

    def creator
      timeline_event.creator_name.presence ||
        timeline_event.creator.try(:name).presence ||
        timeline_event.creator.email
    end

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
              class_context: "timeline-event",
              context: :assessor,
            ),
          ),
        new_state:
          render(
            ApplicationFormStatusTag::Component.new(
              key: timeline_event.id,
              status: timeline_event.new_state,
              class_context: "timeline-event",
              context: :assessor,
            ),
          ),
      }
    end

    def assessor_assigned_vars
      {
        assignee_name:
          timeline_event.assignee&.name.presence ||
            I18n.t("application_form.summary.unassigned"),
      }
    end

    alias_method :reviewer_assigned_vars, :assessor_assigned_vars

    def assessment_section_recorded_vars
      section = timeline_event.assessment_section
      {
        section_name: section.key.titleize,
        section_state:
          render(
            ApplicationFormStatusTag::Component.new(
              key: timeline_event.id,
              status: timeline_event.new_state,
              class_context: "timeline-event",
              context: :assessor,
            ),
          ),
      }
    end

    def note_created_vars
      { text: timeline_event.note.text }
    end

    def further_information_request_assessed_vars
      {
        further_information_request: timeline_event.further_information_request,
      }
    end
  end
end
