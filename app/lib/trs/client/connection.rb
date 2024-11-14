# frozen_string_literal: true

module TRS::Client::Connection
  def connection
    @connection ||=
      Faraday.new(url: Rails.configuration.trs.url) do |faraday|
        faraday.request :authorization,
                        "Bearer",
                        Rails.configuration.trs.api_key
        faraday.request :json
        faraday.response :json
        faraday.response :raise_error
      end
  end
end
