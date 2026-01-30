# frozen_string_literal: true

class Zendesk
  def self.create_request!(**kwargs)
    new(as: kwargs[:email]).create_request!(**kwargs)
  end

  def initialize(as:)
    @as = as
  end

  def create_request!(name:, email:, subject:, comment:)
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
        config.url = Rails.configuration.zendesk.url
        config.username = @as
        config.token = Rails.configuration.zendesk.api_key
      end
  end
end
