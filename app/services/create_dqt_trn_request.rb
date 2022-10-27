# frozen_string_literal: true

class CreateDQTTRNRequest
  include ServicePattern

  def initialize(request_id:, application_form:)
    @request_id = request_id
    @application_form = application_form
  end

  def call
    dqt_trn_request = DQTTRNRequest.find_by(request_id:, application_form:)

    already_existed = dqt_trn_request.present?

    unless already_existed
      dqt_trn_request = DQTTRNRequest.create!(request_id:, application_form:)
    end

    response =
      if already_existed || !dqt_trn_request.initial?
        begin
          DQT::Client::ReadTRNRequest.call(request_id:)
        rescue Faraday::FileNotFound
          DQT::Client::CreateTRNRequest.call(request_id:, application_form:)
        end
      else
        DQT::Client::CreateTRNRequest.call(request_id:, application_form:)
      end

    dqt_trn_request.update_from_dqt_response(response)

    if dqt_trn_request.pending?
      UpdateDQTTRNRequestJob.set(wait: 1.hour).perform_later(dqt_trn_request)
    end

    dqt_trn_request
  end

  private

  attr_reader :request_id, :application_form
end
