# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationMailer do
  describe "after_deliver audit" do
    subject(:deliver_now) { mailer.deliver_now }

    let(:application_form) { create(:application_form, :awarded) }

    let(:mailer) { TeacherMailer.with(application_form:).application_awarded }

    it "creates an EmailDelivery record when an email is delivered" do
      expect { deliver_now }.to change(EmailDelivery, :count).by(1)
    end

    it "records the recipient, subject and mailer details" do
      deliver_now

      delivery = EmailDelivery.last

      expect(delivery).to have_attributes(
        mailer_class_name: "teacher_mailer",
        mailer_action_name: "application_awarded",
        application_form:,
        to: application_form.teacher.email,
        subject: "Your QTS application was successful",
      )
    end

    it "does not enqueue the status update job without notify_id in response" do
      expect { deliver_now }.not_to have_enqueued_job(
        EmailDeliveryNotifyStatusUpdateJob,
      )
    end

    context "when Notify returns a notify_id" do
      let(:notify_response) do
        instance_double(Notifications::Client::Notification, id: "notify-123")
      end

      let(:delivery_method) do
        instance_double(
          Mail::Notify::DeliveryMethod,
          response: notify_response,
          deliver!: true,
        )
      end

      before do
        allow_any_instance_of(Mail::Message).to receive(
          :delivery_method,
        ).and_return(delivery_method)
      end

      it "enqueues the status update job with the record" do
        expect { deliver_now }.to have_enqueued_job(
          EmailDeliveryNotifyStatusUpdateJob,
        )
      end
    end
  end
end
