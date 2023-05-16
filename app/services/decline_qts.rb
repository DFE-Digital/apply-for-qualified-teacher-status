# frozen_string_literal: true

class DeclineQTS
  include ServicePattern

  def initialize(application_form:, user:)
    @application_form = application_form
    @user = user
  end

  def call
    return if application_form.declined?

    ActiveRecord::Base.transaction do
      application_form.update!(declined_at: Time.zone.now)
      ApplicationFormStatusUpdater.call(application_form:, user:)
      if quick_decline?
        CreateQuickDeclineTimelineEvent.call(application_form:, user:)
      end
    end

    TeacherMailer.with(teacher:).application_declined.deliver_later
  end

  private

  attr_reader :application_form, :user
  delegate :teacher, to: :application_form

  def quick_decline?
    application_form.requires_preliminary_check &&
      application_form.assessment&.preliminary_check_complete == false
  end
end
