# frozen_string_literal: true

class CreateDQTTRNRequest
  include ServicePattern

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    request_id = SecureRandom.uuid
    dqt_trn_request = DQTTRNRequest.create!(request_id:, application_form:)

    begin
      response =
        DQT::Client::CreateTRNRequest.call(request_id:, application_form:)
    rescue StandardError
      dqt_trn_request.destroy!
      raise
    end

    # Must not fail from this point, as the TRN request exists in DQT. Any
    # error that happens after this will need to be investigated and fixed.

    begin
      dqt_trn_request.update_from_dqt_response(response)

      if dqt_trn_request.pending?
        UpdateDQTTRNRequestJob.set(wait: 1.hour).perform_later(dqt_trn_request)
      end
    rescue StandardError => e
      Sentry.capture_exception(e)
    end

    dqt_trn_request
  end

  private

  attr_reader :application_form
end
