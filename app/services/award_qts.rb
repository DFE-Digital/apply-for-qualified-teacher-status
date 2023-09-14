# frozen_string_literal: true

class AwardQTS
  include ServicePattern

  def initialize(
    application_form:,
    user:,
    trn:,
    access_your_teaching_qualifications_url:
  )
    @application_form = application_form
    @user = user
    @trn = trn
    @access_your_teaching_qualifications_url =
      access_your_teaching_qualifications_url
  end

  def call
    return if application_form.awarded_at.present?

    raise InvalidState if application_form.dqt_trn_request.nil?

    raise MissingTRN if trn.blank?

    ActiveRecord::Base.transaction do
      teacher.update!(trn:, access_your_teaching_qualifications_url:)
      application_form.update!(awarded_at: Time.zone.now)
      ApplicationFormStatusUpdater.call(application_form:, user:)
    end

    TeacherMailer.with(teacher:).application_awarded.deliver_later
  end

  class InvalidState < StandardError
  end

  class MissingTRN < StandardError
  end

  private

  attr_reader :application_form,
              :user,
              :trn,
              :access_your_teaching_qualifications_url

  delegate :teacher, to: :application_form
end
