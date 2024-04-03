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

    def status_changed_vars
      {
        old_status:
          render(
            StatusTag::Component.new(
              timeline_event.old_value,
              class_context: "timeline-event",
            ),
          ).strip,
        new_status:
          render(
            StatusTag::Component.new(
              timeline_event.new_value,
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

      # to handle old timeline events
      status =
        if timeline_event.new_value == "action_required"
          "rejected"
        elsif timeline_event.new_value == "completed" &&
              timeline_event.is_latest_of_type?
          section.status
        else
          timeline_event.new_value
        end

      selected_failure_reasons =
        (
          if timeline_event.is_latest_of_type?
            section.selected_failure_reasons.to_a
          else
            []
          end
        )

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
        status:,
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

    def requestable_reviewed_vars
      {
        old_status: timeline_event.old_value.presence || "not_started",
        new_status:
          timeline_event.new_value.presence ||
            timeline_event.requestable.review_status,
        note:
          timeline_event.note_text.presence ||
            timeline_event.requestable.review_note,
      }
    end

    def requestable_verified_vars
      {
        old_status: timeline_event.old_value.presence || "not_started",
        new_status:
          timeline_event.new_value.presence ||
            timeline_event.requestable.verify_status,
        note:
          timeline_event.note_text.presence ||
            timeline_event.requestable.verify_note,
      }
    end

    def information_changed_vars
      {
        column_name: timeline_event.column_name,
        old_value: timeline_event.old_value,
        new_value: timeline_event.new_value,
      }
    end

    def action_required_by_changed_vars
      {
        action:
          if timeline_event.new_value == "none"
            "no"
          else
            timeline_event.new_value
          end,
      }
    end

    def stage_changed_vars
      {
        old_stage:
          render(
            StatusTag::Component.new(
              timeline_event.old_value,
              class_context: "timeline-event",
            ),
          ).strip,
        new_stage:
          render(
            StatusTag::Component.new(
              timeline_event.new_value,
              class_context: "timeline-event",
            ),
          ).strip,
      }
    end

    def application_declined_vars
      {}
    end
  end
end
