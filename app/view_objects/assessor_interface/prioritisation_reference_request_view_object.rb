# frozen_string_literal: true

module AssessorInterface
  class PrioritisationReferenceRequestViewObject
    def initialize(prioritisation_reference_request:)
      @prioritisation_reference_request = prioritisation_reference_request
    end

    delegate :assessment,
             :work_history,
             :reminder_emails,
             :email_deliveries,
             to: :prioritisation_reference_request
    delegate :application_form, :prioritisation_decision_at, to: :assessment
    delegate :on_hold?, :timeline_events, to: :application_form

    attr_reader :prioritisation_reference_request

    def disable_form?
      prioritisation_decision_at.present? || on_hold?
    end

    def can_resend_email?
      !prioritisation_reference_request.received? &&
        prioritisation_decision_at.nil?
    end

    def last_sent_at_local_timestamp
      (
        email_deliveries.pluck(:created_at) + reminder_emails.pluck(:created_at)
      ).max || prioritisation_reference_request.created_at
    end
  end
end
