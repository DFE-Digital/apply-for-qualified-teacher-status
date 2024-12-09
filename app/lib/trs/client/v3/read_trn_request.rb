# frozen_string_literal: true

class TRS::Client::V3::ReadTRNRequest
  include ServicePattern
  include TRS::Client::Connection

  def initialize(request_id:)
    @request_id = request_id
  end

  def call
    path = "/v3/trn-requests"
    response =
      connection.get(path) do |req|
        # TODO: Temporary API version and will need to change once in production
        req.headers["X-Api-Version"] = "Next"
        req.params["requestId"] = request_id
      end

    response.body.transform_keys { |key| key.underscore.to_sym }
  end

  private

  attr_reader :request_id
end
