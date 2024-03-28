# frozen_string_literal: true

class UpdateTeacherEmail
  include ServicePattern

  def initialize(application_form:, user:, email:)
    @application_form = application_form
    @user = user
    @email = email
  end

  def call
    raise TeacherAlreadyExists if teacher_already_exists?

    old_email = teacher.email
    return if email.downcase == old_email.downcase

    email_address = EmailAddress.new(email)

    ActiveRecord::Base.transaction do
      teacher.update!(
        email:,
        canonical_email: email_address.canonical,
        email_domain: email_address.host_name,
      )

      create_timeline_event(old_email:)
    end
  end

  class TeacherAlreadyExists < StandardError
  end

  private

  attr_reader :application_form, :user, :email

  delegate :teacher, to: :application_form

  def teacher_already_exists?
    Teacher.find_by_email(email).present?
  end

  def create_timeline_event(old_email:)
    CreateTimelineEvent.call(
      "information_changed",
      application_form:,
      user:,
      column_name: "email",
      old_value: old_email,
      new_value: email,
    )
  end
end
