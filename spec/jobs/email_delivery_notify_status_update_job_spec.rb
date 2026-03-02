# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmailDeliveryNotifyStatusUpdateJob do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(email_delivery) }

    let(:email_delivery) { create :email_delivery }
    let(:stubbed_notify_service) { instance_double(Notifications::Client) }
    let(:response_body) do
      Notifications::Client::Notification.new(
        { "status" => status, "completed_at" => completed_at },
      )
    end

    let(:status) { "sending" }
    let(:completed_at) { nil }

    before do
      allow(Notifications::Client).to receive(:new).and_return(
        stubbed_notify_service,
      )
      allow(stubbed_notify_service).to receive(:get_notification).and_return(
        response_body,
      )
    end

    context "when the response status is sending" do
      let(:status) { "sending" }
      let(:completed_at) { nil }

      it "does not update the status" do
        expect { perform }.not_to change(email_delivery, :notify_status)
      end
    end

    context "when the response status is delivered" do
      let(:status) { "delivered" }
      let(:completed_at) { 5.seconds.ago }

      it "updates the status to delivered" do
        expect { perform }.to change(email_delivery, :notify_status).from(
          "created",
        ).to("delivered").and change(email_delivery, :notify_completed_at).from(
                nil,
              )
      end
    end

    context "when the response status is permanent-failure" do
      let(:status) { "permanent-failure" }
      let(:completed_at) { 5.seconds.ago }

      it "updates the status to permanent-failure" do
        expect { perform }.to change(email_delivery, :notify_status).from(
          "created",
        ).to("permanent_failure").and change(
                email_delivery,
                :notify_completed_at,
              ).from(nil)
      end
    end

    context "when the response status is temporary-failure" do
      let(:status) { "temporary-failure" }
      let(:completed_at) { 5.seconds.ago }

      it "updates the status to temporary-failure" do
        expect { perform }.to change(email_delivery, :notify_status).from(
          "created",
        ).to("temporary_failure").and change(
                email_delivery,
                :notify_completed_at,
              ).from(nil)
      end
    end

    context "when the response status is technical-failure" do
      let(:status) { "technical-failure" }
      let(:completed_at) { 5.seconds.ago }

      it "updates the status to technical-failure" do
        expect { perform }.to change(email_delivery, :notify_status).from(
          "created",
        ).to("technical_failure").and change(
                email_delivery,
                :notify_completed_at,
              ).from(nil)
      end
    end

    context "when email_delivery record already delivered" do
      let(:email_delivery) { create :email_delivery, notify_status: :delivered }

      it "does not update the status to delivered" do
        expect { perform }.not_to change(email_delivery, :notify_status)
      end

      it "does not make a new request to Notify API" do
        perform

        expect(stubbed_notify_service).not_to have_received(:get_notification)
      end
    end

    context "when email_delivery record does not have a notify_id" do
      let(:email_delivery) { create :email_delivery, notify_id: nil }

      it "does not update the status to delivered" do
        expect { perform }.not_to change(email_delivery, :notify_status)
      end

      it "does not make a new request to Notify API" do
        perform

        expect(stubbed_notify_service).not_to have_received(:get_notification)
      end
    end
  end
end
