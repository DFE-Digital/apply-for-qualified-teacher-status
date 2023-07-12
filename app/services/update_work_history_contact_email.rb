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
      UpdateWorkHistoryContact.call(
        work_history:,
        user:,
        email: new_email_address,
      )
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
end
