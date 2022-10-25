# frozen_string_literal: true

class UpdateDQTTRNRequest
  include ServicePattern

  def initialize(dqt_trn_request:)
    @dqt_trn_request = dqt_trn_request
  end

  def call
    suppress(Faraday::Error) do
      dqt_trn_request.update_from_dqt_response(
        DQT::Client::ReadTRNRequest.call(
          request_id: dqt_trn_request.request_id,
        ),
      )
    end
  end

  private

  attr_reader :dqt_trn_request
end
