# frozen_string_literal: true

require "rails_helper"

RSpec.describe TRS::Client::V3::CreateTRNRequest do
  subject(:call) { described_class.call(request_id:, application_form:) }

  let(:request_id) { "request-id" }
  let(:application_form) { create(:application_form) }

  before do
    allow(TRS::V3::TRNRequestParams).to receive(:call).with(
      request_id:,
      application_form:,
    ).and_return("body")
  end

  context "with a successful response" do
    before do
      stub_request(
        :post,
        "https://test-teacher-qualifications-api.education.gov.uk/v3/trn-requests",
      ).with(
        body: "body",
        headers: {
          "X-Api-Version" => "20250425",
          "Authorization" => "Bearer test-api-key",
          "Content-Type" => "application/json",
        },
      ).to_return(
        status: 200,
        body:
          '{"requestId":"72888c5d-db14-4222-829b-7db9c2ec0dc3","status":"Completed",' \
            '"trn":"1234567","potentialDuplicate":false,"accessYourTeachingQualificationsLink":null}',
        headers: {
          "Content-Type" => "application/json",
        },
      )
    end

    it do
      expect(subject).to eq(
        {
          request_id: "72888c5d-db14-4222-829b-7db9c2ec0dc3",
          status: "Completed",
          trn: "1234567",
          potential_duplicate: false,
          access_your_teaching_qualifications_link: nil,
        },
      )
    end
  end

  context "with a failure response" do
    before do
      stub_request(
        :post,
        "https://test-teacher-qualifications-api.education.gov.uk/v3/trn-requests",
      ).with(
        body: "body",
        headers: {
          "X-Api-Version" => "20250425",
          "Authorization" => "Bearer test-api-key",
          "Content-Type" => "application/json",
        },
      ).to_return(
        status: 400,
        body: nil,
        headers: {
          "Content-Type" => "application/json",
        },
      )
    end

    it "raises an error" do
      expect { call }.to raise_error(Faraday::BadRequestError)
    end
  end
end
