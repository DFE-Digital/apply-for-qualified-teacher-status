# frozen_string_literal: true

class TRS::Client::V3::CreateTRNRequest
  include ServicePattern
  include TRS::Client::Connection

  def initialize(request_id:, application_form:)
    @request_id = request_id
    @application_form = application_form
  end

  def call
    path = "/v3/trn-requests"
    body = TRS::V3::TRNRequestParams.call(request_id:, application_form:)
    response =
      connection.post(path) do |req|
        req.headers["X-Api-Version"] = "20250627"
        req.body = body
      end

    response.body.transform_keys { |key| key.underscore.to_sym }
  end

  private

  attr_reader :request_id, :application_form
end
