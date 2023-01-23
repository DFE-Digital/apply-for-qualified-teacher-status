# frozen_string_literal: true

class AwardQTS
  include ServicePattern

  def initialize(application_form:, user:, trn:)
    @application_form = application_form
    @user = user
    @trn = trn
  end

  def call
    return if application_form.awarded?

    unless application_form.awarded_pending_checks? ||
             application_form.potential_duplicate_in_dqt?
      raise InvalidState
    end

    raise MissingTRN if trn.blank?

    ActiveRecord::Base.transaction do
      teacher.update!(trn:)
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

  attr_reader :application_form, :user, :trn

  delegate :teacher, to: :application_form
end
