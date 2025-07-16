# frozen_string_literal: true

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
        elsif timeline_event.assessment_section_recorded?
          preliminary_or_not =
            (
              if timeline_event.assessment_section.preliminary?
                "preliminary"
              else
                "not_preliminary"
              end
            )

          "components.timeline_entry.title.assessment_section_recorded" \
            ".#{preliminary_or_not}.#{timeline_event.assessment_section.key}"
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
          render(StatusTag::Component.new(timeline_event.old_value)).strip,
        new_status:
          render(StatusTag::Component.new(timeline_event.new_value)).strip,
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
      assessment_section = timeline_event.assessment_section

      is_most_recent =
        timeline_event
          .application_form
          .timeline_events
          .assessment_section_recorded
          .order(created_at: :desc)
          .find_by(assessment_section:) == timeline_event

      # We need to transform the previous status values that aren't
      # suitable for presenting to the user.
      status =
        if timeline_event.new_value == "action_required"
          "rejected"
        elsif timeline_event.new_value == "completed" && is_most_recent
          assessment_section.status
        else
          timeline_event.new_value
        end

      # We can only show failure reasons for the most recent timeline
      # event as we pull them direct from the assessment section.
      selected_failure_reasons =
        (
          if is_most_recent
            assessment_section.selected_failure_reasons.to_a
          else
            []
          end
        )

      {
        section_name: assessment_section.key.titleize,
        status:,
        failure_reasons: selected_failure_reasons,
      }
    end

    def prioritisation_work_history_check_recorded_vars
      prioritisation_work_history_check =
        timeline_event.prioritisation_work_history_check

      is_most_recent =
        timeline_event
          .application_form
          .timeline_events
          .prioritisation_work_history_check_recorded
          .order(created_at: :desc)
          .find_by(prioritisation_work_history_check:) == timeline_event

      # We can only show failure reasons for the most recent timeline
      # event as we pull them direct from the assessment section.
      selected_failure_reasons =
        (
          if is_most_recent
            prioritisation_work_history_check.selected_failure_reasons.to_a
          else
            []
          end
        )

      {
        institution_name:
          prioritisation_work_history_check.work_history.school_name,
        status: timeline_event.new_value,
        failure_reasons: selected_failure_reasons,
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
        requested_at: timeline_event.requestable.created_at.to_fs,
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
          render(StatusTag::Component.new(timeline_event.old_value)).strip,
        new_stage:
          render(StatusTag::Component.new(timeline_event.new_value)).strip,
      }
    end

    def application_declined_vars
      {}
    end
  end
end
