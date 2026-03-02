# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmailDeliveryAuditJob do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(*params) }

    let(:params) do
      [
        to,
        email_subject,
        notify_id,
        mailer_class_name,
        mailer_action_name,
        mailer_params,
      ]
    end

    let(:to) { "test@example.com" }
    let(:notify_id) { "123456789" }
    let(:email_subject) { "Test email" }
    let(:mailer_class_name) { "teacher_mailer" }
    let(:mailer_action_name) { "application_received" }

    let(:mailer_params) { { application_form: } }

    let(:application_form) do
      create(:application_form, :submitted, :with_assessment)
    end

    it "creates a new email record" do
      expect { perform }.to change(EmailDelivery, :count).by(1)

      email_delivery = EmailDelivery.last

      expect(email_delivery).to have_attributes(
        to:,
        subject: email_subject,
        notify_id:,
        mailer_class_name:,
        mailer_action_name:,
        application_form:,
      )
    end

    it "enqueues a job for EmailDeliveryNotifyStatusUpdateJob" do
      expect { perform }.to have_enqueued_job(
        EmailDeliveryNotifyStatusUpdateJob,
      ).with(EmailDelivery.last)
    end

    context "when reference_request is present in mailer params" do
      let(:reference_request) do
        create :requested_reference_request,
               assessment: application_form.assessment
      end
      let(:mailer_params) { { application_form:, reference_request: } }

      it "creates a new email record with reference request assigned" do
        expect { perform }.to change(EmailDelivery, :count).by(1)

        email_delivery = EmailDelivery.last

        expect(email_delivery).to have_attributes(
          to:,
          subject: email_subject,
          notify_id:,
          mailer_class_name:,
          mailer_action_name:,
          application_form:,
          reference_request:,
        )
      end
    end

    context "when prioritisation_reference_request is present in mailer params" do
      let(:prioritisation_reference_request) do
        create :requested_prioritisation_reference_request,
               assessment: application_form.assessment
      end
      let(:mailer_params) do
        { application_form:, prioritisation_reference_request: }
      end

      it "creates a new email record with prioritisation reference request assigned" do
        expect { perform }.to change(EmailDelivery, :count).by(1)

        email_delivery = EmailDelivery.last

        expect(email_delivery).to have_attributes(
          to:,
          subject: email_subject,
          notify_id:,
          mailer_class_name:,
          mailer_action_name:,
          application_form:,
          prioritisation_reference_request:,
        )
      end
    end

    context "when further_information_request is present in mailer params" do
      let(:further_information_request) do
        create :requested_further_information_request,
               assessment: application_form.assessment
      end
      let(:mailer_params) do
        { application_form:, further_information_request: }
      end

      it "creates a new email record with prioritisation reference request assigned" do
        expect { perform }.to change(EmailDelivery, :count).by(1)

        email_delivery = EmailDelivery.last

        expect(email_delivery).to have_attributes(
          to:,
          subject: email_subject,
          notify_id:,
          mailer_class_name:,
          mailer_action_name:,
          application_form:,
          further_information_request:,
        )
      end
    end

    context "when no notify_id is passed in" do
      let(:notify_id) { nil }

      it "creates a new email record without notify_id" do
        expect { perform }.to change(EmailDelivery, :count).by(1)

        email_delivery = EmailDelivery.last

        expect(email_delivery).to have_attributes(
          to:,
          subject: email_subject,
          notify_id: nil,
          mailer_class_name:,
          mailer_action_name:,
          application_form:,
        )
      end

      it "does not enqueue a job for EmailDeliveryNotifyStatusUpdateJob" do
        expect { perform }.not_to have_enqueued_job(
          EmailDeliveryNotifyStatusUpdateJob,
        )
      end
    end
  end
end
