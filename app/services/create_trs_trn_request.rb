# frozen_string_literal: true

class CreateTRSTRNRequest
  include ServicePattern

  def initialize(application_form:, user:)
    @application_form = application_form
    @user = user
  end

  def call
    request_id = SecureRandom.uuid
    dqt_trn_request = DQTTRNRequest.create!(request_id:, application_form:)
    ApplicationFormStatusUpdater.call(application_form:, user:)
    UpdateTRSTRNRequestJob.perform_later(dqt_trn_request)
  end

  private

  attr_reader :application_form, :user
end
