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
            StatusTag::Component.new(
              key: timeline_event.id,
              status: timeline_event.old_state,
              class_context: "timeline-event",
              context: :assessor,
            ),
          ).strip,
        new_state:
          render(
            StatusTag::Component.new(
              key: timeline_event.id,
              status: timeline_event.new_state,
              class_context: "timeline-event",
              context: :assessor,
            ),
          ).strip,
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
        section_state: timeline_event.new_state,
        failure_reasons: section.selected_failure_reasons,
      }
    end

    def note_created_vars
      { text: timeline_event.note.text }
    end

    def further_information_request_assessed_vars
      further_information_request = timeline_event.further_information_request
      {
        passed: further_information_request.passed,
        failure_assessor_note:
          further_information_request.failure_assessor_note,
      }
    end

    def further_information_request_expired_vars
      {
        further_information_request: timeline_event.further_information_request,
        date_requested:
          timeline_event.further_information_request.created_at.strftime(
            "%e %B %Y at %l:%M %P",
          ),
      }
    end

    def email_sent_vars
      {
        subject:
          I18n.t("mailer.teacher.#{timeline_event.mailer_action_name}.subject"),
      }
    end

    def age_range_subjects_verified_vars
      assessment = timeline_event.assessment

      {
        age_range_min: assessment.age_range_min,
        age_range_max: assessment.age_range_max,
        age_range_note: assessment.age_range_note,
        subjects: Subject.find(assessment.subjects).map(&:name).join(", "),
        subjects_note: assessment.subjects_note,
      }
    end
  end
end
