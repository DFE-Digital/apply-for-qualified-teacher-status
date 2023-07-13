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
    end
  end

  private

  attr_reader :work_history, :user, :name, :job, :email

  delegate :application_form, to: :work_history

  def change_value(column_name, new_value)
    old_value = work_history.send(column_name)
    work_history.update!(column_name => new_value)
    create_timeline_event(column_name, old_value, new_value)
  end

  def create_timeline_event(column_name, old_value, new_value)
    TimelineEvent.create!(
      event_type: "information_changed",
      application_form:,
      creator: user,
      work_history:,
      column_name:,
      old_value:,
      new_value:,
    )
  end
end
