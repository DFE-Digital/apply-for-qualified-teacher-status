# frozen_string_literal: true

class CreateTRSTRNRequest
  include ServicePattern

  def initialize(application_form:, user:)
    @application_form = application_form
    @user = user
  end

  def call
    request_id = SecureRandom.uuid
    trs_trn_request = TRSTRNRequest.create!(request_id:, application_form:)
    ApplicationFormStatusUpdater.call(application_form:, user:)
    UpdateTRSTRNRequestJob.perform_later(trs_trn_request)
  end

  private

  attr_reader :application_form, :user
end
