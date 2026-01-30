# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/VerifiedDoubles
RSpec.describe Zendesk do
  subject(:zendesk) { described_class }

  let(:client) { double(ZendeskAPI::Client) }

  let(:config) { double }

  before do
    allow(ZendeskAPI::Client).to receive(:new).and_return(client).and_yield(
      config,
    )

    allow(config).to receive(:url=)
    allow(config).to receive(:username=)
    allow(config).to receive(:token=)
  end

  describe ".create_request!" do
    let(:name) { "John Smith" }
    let(:email) { "test@example.com" }
    let(:comment) { "I need some help!" }
    let(:ticket_subject) { "[AfQTS PR] Support request" }

    let(:kwargs) { { name:, email:, comment:, subject: ticket_subject } }

    let(:requests) { double(create!: nil) }

    before { allow(client).to receive_messages(requests: requests) }

    it "uses the end user's email as the API username" do
      zendesk.create_request!(**kwargs)

      expect(config).to have_received(:username=).with(email)
    end

    it "creates a formatted request" do
      zendesk.create_request!(**kwargs)

      expect(requests).to have_received(:create!).with(
        requester: {
          name:,
          email:,
        },
        subject: ticket_subject,
        comment: {
          body: comment,
        },
      )
    end

    describe "client configuration" do
      let(:api_key) { SecureRandom.uuid }
      let(:url) { "https://test.zendesk.com/api/v2" }

      before do
        allow(Rails.configuration.zendesk).to receive_messages(
          url: url,
          api_key: api_key,
        )
      end

      it "sets the URL" do
        zendesk.create_request!(**kwargs)
        expect(config).to have_received(:url=).with(url)
      end

      it "sets the end user's email" do
        zendesk.create_request!(**kwargs)
        expect(config).to have_received(:username=).with(email)
      end

      it "sets the API token" do
        zendesk.create_request!(**kwargs)
        expect(config).to have_received(:token=).with(api_key)
      end
    end
  end
end
# rubocop:enable RSpec/VerifiedDoubles
