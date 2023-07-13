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

    def title
      locale_key =
        if timeline_event.requestable_event_type?
          "components.timeline_entry.title.#{timeline_event.event_type}.#{timeline_event.requestable.class.name}"
        else
          "components.timeline_entry.title.#{timeline_event.event_type}"
        end

      I18n.t(locale_key)
    end

    def description
      locale_key =
        if timeline_event.requestable_event_type?
          "components.timeline_entry.description.#{timeline_event.event_type}.#{timeline_event.requestable.class.name}"
        else
          "components.timeline_entry.description.#{timeline_event.event_type}"
        end

      I18n.t(locale_key, **description_vars)
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
              status: timeline_event.old_state,
              class_context: "timeline-event",
            ),
          ).strip,
        new_state:
          render(
            StatusTag::Component.new(
              status: timeline_event.new_state,
              class_context: "timeline-event",
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
      selected_failure_reasons = section.selected_failure_reasons

      visible_failure_reasons =
        (
          if selected_failure_reasons.count <= 2
            selected_failure_reasons
          else
            selected_failure_reasons.take(1)
          end
        )

      hidden_failure_reasons =
        (
          if selected_failure_reasons.count <= 2
            []
          else
            selected_failure_reasons.drop(1)
          end
        )

      {
        section_name: section.key.titleize,
        passed: section.passed,
        visible_failure_reasons:,
        hidden_failure_reasons:,
      }
    end

    def note_created_vars
      { text: timeline_event.note.text }
    end

    def email_sent_vars
      {
        subject:
          timeline_event.message_subject.presence ||
            I18n.t(
              "mailer.teacher.#{timeline_event.mailer_action_name}.subject",
            ),
      }
    end

    def age_range_subjects_verified_vars
      {
        age_range_min: timeline_event.age_range_min,
        age_range_max: timeline_event.age_range_max,
        age_range_note: timeline_event.age_range_note,
        subjects: Subject.find(timeline_event.subjects).map(&:name).join(", "),
        subjects_note: timeline_event.subjects_note,
      }
    end

    def requestable_requested_vars
      {}
    end

    def requestable_received_vars
      {
        requested_at:
          timeline_event.requestable.created_at.to_fs(:date_and_time),
        location_note: timeline_event.requestable.try(:location_note),
      }
    end

    alias_method :requestable_expired_vars, :requestable_received_vars

    def requestable_assessed_vars
      requestable = timeline_event.requestable

      case requestable
      when FurtherInformationRequest
        {
          passed: requestable.passed,
          failure_assessor_note: requestable.failure_assessor_note,
        }
      else
        {}
      end
    end
  end
end
