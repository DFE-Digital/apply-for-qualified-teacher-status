# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateZendeskRequestJob do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(support_request) }

    let(:support_request) { create(:support_request) }

    let(:zendesk_response) do
      OpenStruct.new(id: "12345", created_at: Time.current)
    end

    before do
      allow(Zendesk).to receive(:create_request!).and_return(zendesk_response)
    end

    it "calls creates a request on Zendesk with correct subject" do
      perform

      expect(Zendesk).to have_received(:create_request!).with(
        name: support_request.name,
        email: support_request.email,
        subject: "[AfQTS PR] Support request",
        comment: support_request.comment,
      )
    end

    it "updates the Zendesk id and created_at timestamp on the support request record" do
      freeze_time do
        expect { perform }.to change(support_request, :zendesk_ticket_id).from(
          nil,
        ).to(zendesk_response.id).and change(
                support_request,
                :zendesk_ticket_created_at,
              ).from(nil).to(zendesk_response.created_at)
      end
    end

    context "when the support request is from a user who has not yet submitted application" do
      let(:support_request) do
        create(:support_request, :submitting_an_application_category)
      end

      it "calls creates a request on Zendesk with correct subject" do
        perform

        expect(Zendesk).to have_received(:create_request!).with(
          name: support_request.name,
          email: support_request.email,
          subject: "[AfQTS Ops] Support request",
          comment: support_request.comment,
        )
      end
    end

    context "when the support request is from a user who has submitted application" do
      let(:support_request) do
        create(:support_request, :application_submitted_category)
      end

      it "calls creates a request on Zendesk with correct subject" do
        perform

        expect(Zendesk).to have_received(:create_request!).with(
          name: support_request.name,
          email: support_request.email,
          subject:
            "[AfQTS PR] Support request for #{support_request.application_reference}",
          comment: support_request.comment,
        )
      end

      context "with enquiry type being application progress update" do
        let(:support_request) do
          create(
            :support_request,
            :application_submitted_category,
            application_enquiry_type: "progress_update",
          )
        end

        it "calls creates a request on Zendesk with correct subject" do
          perform

          expect(Zendesk).to have_received(:create_request!).with(
            name: support_request.name,
            email: support_request.email,
            subject:
              "[AfQTS Ops] Support request for #{support_request.application_reference}",
            comment: support_request.comment,
          )
        end
      end
    end

    context "when the support request is from a referee" do
      let(:support_request) do
        create(:support_request, :providing_a_reference_category)
      end

      it "calls creates a request on Zendesk with correct subject" do
        perform

        expect(Zendesk).to have_received(:create_request!).with(
          name: support_request.name,
          email: support_request.email,
          subject: "[AfQTS PR] Support request",
          comment: support_request.comment,
        )
      end
    end
  end
end
