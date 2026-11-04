# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /support-requests", type: :request do
  let(:user_type) { "other" }
  let(:form_params) do
    {
      name: "Test User",
      email: "test@example.com",
      comment: "I need some help submitting my application.",
      user_type:,
      application_reference: "000001",
      application_enquiry_type: "progress_update",
    }
  end

  around do |example|
    FeatureFlags::FeatureFlag.activate(:support_request_form)
    example.run
    FeatureFlags::FeatureFlag.deactivate(:support_request_form)
  end

  it "saves the request without application details for another user type" do
    post support_requests_path, params: { support_request_form: form_params }

    expect(CreateZendeskRequestJob).to have_been_enqueued.with(
      SupportRequest.last,
    )

    expect(response).to redirect_to(confirmation_support_requests_path)
    expect(SupportRequest.last).to have_attributes(
      form_params.merge(
        application_reference: nil,
        application_enquiry_type: nil,
      ),
    )
  end

  context "when user_type is application_submitted" do
    let(:user_type) { "application_submitted" }

    it "saves the request with its application details" do
      post support_requests_path, params: { support_request_form: form_params }

      expect(CreateZendeskRequestJob).to have_been_enqueued.with(
        SupportRequest.last,
      )

      expect(response).to redirect_to(confirmation_support_requests_path)
      expect(SupportRequest.last).to have_attributes(form_params)
    end
  end
end
