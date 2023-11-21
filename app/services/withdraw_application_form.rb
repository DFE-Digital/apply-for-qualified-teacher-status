# frozen_string_literal: true

class WithdrawApplicationForm
  include ServicePattern

  def initialize(application_form:, user:)
    @application_form = application_form
    @user = user
  end

  def call
    return if application_form.withdrawn_at.present?

    ActiveRecord::Base.transaction do
      application_form.update!(withdrawn_at: Time.zone.now)
      ApplicationFormStatusUpdater.call(application_form:, user:)
    end
  end

  private

  attr_reader :application_form, :user
end
