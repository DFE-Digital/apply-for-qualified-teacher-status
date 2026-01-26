# frozen_string_literal: true

module GovUKPay::Client::Connection
  def connection
    @connection ||=
      Faraday.new(url: Rails.configuration.gov_uk_pay.base_url) do |faraday|
        faraday.request :authorization,
                        "Bearer",
                        Rails.configuration.gov_uk_pay.api_key
        faraday.request :json
        faraday.response :json
        faraday.response :raise_error
      end
  end
end
