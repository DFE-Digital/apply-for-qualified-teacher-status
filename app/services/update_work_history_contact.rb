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
    ActiveRecord::Base.transaction do
      change_value("contact_name", name) if name.present?

      change_value("contact_job", job) if job.present?

      if email.present?
        change_value("contact_email", email)
        work_history.update!(
          canonical_contact_email: EmailAddress.canonical(email),
        )
      end
    end

    if email.present? && (reference_request = work_history.reference_request)
      RefereeMailer.with(reference_request:).reference_requested.deliver_later
      TeacherMailer
        .with(teacher:, reference_requests: [reference_request])
        .references_requested
        .deliver_later
    end
  end

  private

  attr_reader :work_history, :user, :name, :job, :email

  delegate :application_form, to: :work_history
  delegate :teacher, to: :application_form

  def change_value(column_name, new_value)
    old_value = work_history.send(column_name)
    work_history.update!(column_name => new_value)
    create_timeline_event(column_name, old_value, new_value)
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
end
