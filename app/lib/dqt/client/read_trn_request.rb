# frozen_string_literal: true

class DQT::Client::ReadTRNRequest
  include ServicePattern
  include DQT::Client::Connection

  def initialize(request_id:)
    @request_id = request_id
  end

  def call
    path = "/v2/trn-requests/#{request_id}"
    connection.get(path).body.transform_keys { |key| key.underscore.to_sym }
  end

  private

  attr_reader :request_id
end
