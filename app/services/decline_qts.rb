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
    end

    TeacherMailer.with(application_form:).application_declined.deliver_later
  end

  private

  attr_reader :application_form, :user
end
