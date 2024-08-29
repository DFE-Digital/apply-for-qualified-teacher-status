# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationMailer, type: :mailer do
  describe ".rescue_from" do
    fake_mailer =
      Class.new(ApplicationMailer) do
        self.delivery_method = :notify
        self.notify_settings = {
          api_key:
            "not-real-e1f4c969-b675-4a0d-a14d-623e7c2d3fd8-24fea27b-824e-4259-b5ce-1badafe98150",
        }

        def test_notify_error
          view_mail("testGOVUK_NOTIFY_TEMPLATE_ID_APPLICATION", to: "test@example.com", subject: "Some subject")
        end
      end

    it "marks errors as failed and re-raises the error" do
      stub_request(
        :post,
        "https://api.notifications.service.gov.uk/v2/notifications/email",
      ).to_return(status: 404)

      expect { fake_mailer.test_notify_error.deliver_now }.to raise_error(
        Notifications::Client::NotFoundError,
      )

      failure = MailDeliveryFailure.last
      expect(failure).not_to be_nil
      expect(failure.email_address).to eq("test@example.com")
      expect(failure.mailer_action_method).to eq("test_notify_error")
      expect(failure.mailer_class).to eq("anonymous")
    end
  end
end
