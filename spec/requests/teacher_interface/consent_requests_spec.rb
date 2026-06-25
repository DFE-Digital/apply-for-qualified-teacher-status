# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher Interface - Consent Requests", type: :request do
  let(:teacher) { create(:teacher) }
  let(:application_form) { create(:application_form, teacher:) }
  let(:assessment) { create(:assessment, application_form:) }

  before do
    sign_in teacher, scope: :teacher
    application_form.update!(assessment:)
  end

  describe "POST /teacher/application/consent-requests/submit" do
    subject(:perform) do
      post submit_teacher_interface_application_form_consent_requests_path(
             application_form,
           )
    end

    context "when all consent requests are already received" do
      before do
        create(:received_consent_request, assessment:)
        create(:received_consent_request, assessment:)
      end

      it "redirects safely to the application form without DoubleRenderError" do
        perform
        expect(response).to redirect_to(%i[teacher_interface application_form])
      end

      it "does not deliver a submission email" do
        expect(DeliverEmail).not_to receive(:call)
        perform
      end

      it "does not attempt to receive the requestables again" do
        expect(ReceiveRequestable).not_to receive(:call)
        perform
      end
    end

    context "when there are unreceived consent requests" do
      before do
        create(:received_consent_request, assessment:)
        create(:requested_consent_request, assessment:)
      end

      it "redirects safely to the application form without DoubleRenderError" do
        perform
        expect(response).to redirect_to(%i[teacher_interface application_form])
      end

      it "delivers a submission email" do
        expect(DeliverEmail).to receive(:call)
        perform
      end
    end

    context "when both consent requests are requested" do
      before do
        create(:requested_consent_request, assessment:)
        create(:requested_consent_request, assessment:)
      end

      it "redirects safely to the application form without DoubleRenderError" do
        perform
        expect(response).to redirect_to(%i[teacher_interface application_form])
      end

      it "delivers a submission email" do
        expect(DeliverEmail).to receive(:call)
        perform
      end

      it "calls ReceiveRequestable twice" do
        expect(ReceiveRequestable).to receive(:call).twice
        perform
      end
    end
  end
end
