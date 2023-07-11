# frozen_string_literal: true

class UpdateWorkHistoryContactEmail
  include ServicePattern

  def initialize(
    application_form:,
    user:,
    old_email_address:,
    new_email_address:
  )
    @application_form = application_form
    @user = user
    @old_email_address = old_email_address
    @new_email_address = new_email_address
  end

  def call
    work_histories.each do |work_history|
      work_history.update!(
        contact_email: new_email_address,
        canonical_contact_email: EmailAddress.canonical(new_email_address),
      )

      if (reference_request = work_history.reference_request)
        RefereeMailer.with(reference_request:).reference_requested.deliver_later
      end

      create_timeline_event(work_history)
    end
  end

  private

  attr_reader :application_form, :user, :old_email_address, :new_email_address

  def work_histories
    application_form.work_histories.where(
      "LOWER(contact_email) = ?",
      old_email_address.downcase,
    )
  end

  def create_timeline_event(work_history)
    TimelineEvent.create!(
      event_type: "information_changed",
      application_form:,
      creator: user,
      work_history:,
      column_name: "contact_email",
      old_value: old_email_address,
      new_value: new_email_address,
    )
  end
end
