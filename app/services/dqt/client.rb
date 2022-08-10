# frozen_string_literal: true

module Dqt
  class Client
    class Request
      include HTTParty
      base_uri Rails.configuration.dqt.url
      headers "Accept" => "application/json",
        "Content-Type" => "application/json;odata.metadata=minimal",
        "Authorization" => "Bearer #{Rails.configuration.dqt.api_key}"
    end

    class HttpError < StandardError
    end

    GET_SUCCESSES = [200].freeze
    PUT_SUCCESSES = [200, 201].freeze
    PATCH_SUCCESSES = [204].freeze

    def self.get(...)
      response = Request.get(...)

      handle_response(response:, statuses: GET_SUCCESSES)
    end

    def self.put(...)
      response = Request.put(...)

      handle_response(response:, statuses: PUT_SUCCESSES)
    end

    def self.patch(...)
      response = Request.patch(...)

      handle_response(response:, statuses: PATCH_SUCCESSES)
    end

    def self.handle_response(response:, statuses:)
      if statuses.include?(response.code)
        return JSON.parse(response.body || "{}")
      end

      raise(
        HttpError,
        "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      )
    end
  end
end
