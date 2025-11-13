# frozen_string_literal: true

module AssessorInterface
  class ReferenceRequestViewObject
    def initialize(reference_request:)
      @reference_request = reference_request
    end

    delegate :assessment,
             :work_history,
             :reminder_emails,
             to: :reference_request
    delegate :application_form, to: :assessment
    delegate :on_hold?, :timeline_events, to: :application_form

    attr_reader :reference_request

    def can_resend_email?
      !reference_request.received? && assessment.verify?
    end

    def last_sent_at_local_timestamp
      # TODO: Currently, our system is not designed to accurately
      # determine the last sent email of a specific reference request
      # We plan on improving the way we keep track of all email
      # communications sent via our system and not only rely on timeline events.
      (
        timeline_events
          .email_sent
          .where(
            mailer_class_name: "RefereeMailer",
            mailer_action_name: "reference_requested",
          )
          .pluck(:created_at) + reminder_emails.pluck(:created_at)
      ).max || reference_request.created_at
    end
  end
end
