# frozen_string_literal: true

class DQT::Client::CreateTRNRequest
  include ServicePattern
  include DQT::Client::Connection

  def initialize(request_id:, application_form:)
    @request_id = request_id
    @application_form = application_form
  end

  def call
    path = "/v2/trn-requests/#{request_id}"
    body = DQT::TRNRequestParams.call(application_form:)
    connection
      .put(path, body)
      .body
      .transform_keys { |key| key.underscore.to_sym }
  end

  private

  attr_reader :request_id, :application_form
end
