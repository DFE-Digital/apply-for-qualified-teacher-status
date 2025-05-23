# frozen_string_literal: true

class AwardQTS
  include ServicePattern

  def initialize(
    application_form:,
    user:,
    trn:,
    access_your_teaching_qualifications_url:,
    awarded_at:
  )
    @application_form = application_form
    @user = user
    @trn = trn
    @awarded_at = awarded_at
    @access_your_teaching_qualifications_url =
      access_your_teaching_qualifications_url
  end

  def call
    return if application_form.awarded_at.present?

    raise InvalidState if application_form.trs_trn_request.nil?

    raise MissingTRN if trn.blank?

    ActiveRecord::Base.transaction do
      application_form.teacher.update!(
        trn:,
        access_your_teaching_qualifications_url:,
      )
      application_form.update!(awarded_at:)
      ApplicationFormStatusUpdater.call(application_form:, user:)
    end

    DeliverEmail.call(
      application_form:,
      mailer: TeacherMailer,
      action: :application_awarded,
    )
  end

  class InvalidState < StandardError
  end

  class MissingTRN < StandardError
  end

  private

  attr_reader :application_form,
              :user,
              :trn,
              :awarded_at,
              :access_your_teaching_qualifications_url
end
