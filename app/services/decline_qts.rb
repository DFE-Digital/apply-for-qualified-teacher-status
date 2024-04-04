# frozen_string_literal: true

class DeclineQTS
  include ServicePattern

  def initialize(application_form:, user:)
    @application_form = application_form
    @user = user
  end

  def call
    return if application_form.declined_at.present?

    ActiveRecord::Base.transaction do
      application_form.update!(declined_at: Time.zone.now)
      ApplicationFormStatusUpdater.call(application_form:, user:)
      CreateTimelineEvent.call("application_declined", application_form:, user:)
    end

    DeliverEmail.call(
      application_form:,
      mailer: TeacherMailer,
      action: :application_declined,
    )
  end

  private

  attr_reader :application_form, :user
end
