# frozen_string_literal: true

class Zendesk
  def self.create_ticket!(**kwargs)
    new(as: kwargs[:email]).create_ticket!(**kwargs)
  end

  def initialize(as:)
    if api_key.blank?
      raise ConfigurationError,
            "Please set ZENDESK_API_KEY for this environment."
    end

    if api_username.blank?
      raise ConfigurationError,
            "Please set ZENDESK_API_USERNAME for this environment."
    end

    @as = as
  end

  def create_ticket!(name:, email:, subject:, comment:)
    client.requests.create!(
      comment: {
        body: comment,
      },
      requester: {
        name: name,
        email: email,
      },
      subject:,
    )
  end

  private

  def client
    # https://github.com/zendesk/zendesk_api_client_rb#configuration
    @client ||=
      ZendeskAPI::Client.new do |config|
        config.url = "https://becomingateacher1721898822.zendesk.com/api/v2"
        # config.url = "https://becomingateacher.zendesk.com/api/v2"

        config.username = @as
        config.token = api_key
      end
  end

  def api_key
    @api_key ||= ENV.fetch("ZENDESK_API_KEY", nil)
  end

  def api_username
    @api_username ||= ENV.fetch("ZENDESK_API_USERNAME", nil)
  end

  class ConfigurationError < StandardError
  end
end
