# frozen_string_literal: true

module DQT::Client::Connection
  def connection
    @connection ||=
      Faraday.new(url: Rails.configuration.dqt.url) do |faraday|
        faraday.request :authorization,
                        "Bearer",
                        Rails.configuration.dqt.api_key
        faraday.request :json
        faraday.response :json
        faraday.response :raise_error
      end
  end
end
