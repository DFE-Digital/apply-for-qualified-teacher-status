# frozen_string_literal: true

class CreateDQTTRNRequest
  include ServicePattern

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    request_id = SecureRandom.uuid
    dqt_trn_request = DQTTRNRequest.create!(request_id:, application_form:)

    suppress(Faraday::Error) do
      dqt_trn_request.update_from_dqt_response(
        DQT::Client::CreateTRNRequest.call(request_id:, application_form:),
      )
    end

    dqt_trn_request
  end

  private

  attr_reader :application_form
end
