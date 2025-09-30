# frozen_string_literal: true

class UpdateWorkHistoryContact
  include ServicePattern

  def initialize(work_history:, user:, name: nil, job: nil, email: nil)
    @work_history = work_history
    @user = user
    @name = name
    @job = job
    @email = email
  end

  def call
    if reference_request.present? && reference_request.received?
      raise InvalidState, "Reference has already been received."
    end

    change_value("contact_name", name) if name.present?

    change_value("contact_job", job) if job.present?

    if email.present?
      email_address = EmailAddress.new(email)

      change_value(
        "contact_email",
        email,
        additional_updates: {
          canonical_contact_email: email_address.canonical,
          contact_email_domain: email_address.host_name,
        },
      )

      schedule_eligibility_domain_match_job_for_new_email

      if reference_request.present?
        reference_request.regenerate_slug

        RequestRequestable.call(
          requestable: reference_request,
          user:,
          allow_already_requested: true,
        )

        ApplicationFormStatusUpdater.call(application_form:, user:)

        DeliverEmail.call(
          application_form:,
          mailer: TeacherMailer,
          action: :references_requested,
          reference_requests: [reference_request],
        )
      end
    end
  end

  private

  attr_reader :work_history, :user, :name, :job, :email

  delegate :application_form, :reference_request, to: :work_history

  def change_value(column_name, new_value, additional_updates: {})
    old_value = work_history.send(column_name)

    ActiveRecord::Base.transaction do
      work_history.update!(column_name => new_value, **additional_updates)
      create_timeline_event(column_name, old_value, new_value)
    end
  end

  def create_timeline_event(column_name, old_value, new_value)
    CreateTimelineEvent.call(
      "information_changed",
      application_form:,
      user:,
      work_history:,
      column_name:,
      old_value:,
      new_value:,
    )
  end

  def schedule_eligibility_domain_match_job_for_new_email
    EligibilityDomainMatchers::WorkHistoryMatchJob.perform_later(work_history)
  end

  class InvalidState < StandardError
  end
end
