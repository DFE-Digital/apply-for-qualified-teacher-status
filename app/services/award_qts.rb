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
    raise MustBePendingChecks unless application_form.awarded_pending_checks?

    ActiveRecord::Base.transaction do
      teacher.update!(trn:)

      application_form.update!(awarded_at: Time.zone.now)

      ChangeApplicationFormState.call(
        application_form:,
        user:,
        new_state: "awarded",
      )
    end

    TeacherMailer.with(teacher:).application_awarded.deliver_later
  end

  class MustBePendingChecks < StandardError
  end

  private

  attr_reader :application_form, :user, :trn

  delegate :teacher, to: :application_form
end
