# frozen_string_literal: true

require "rails_helper"

RSpec.describe TRS::Client::V3::ReadTRNRequest do
  subject(:call) { described_class.call(request_id:) }

  let(:request_id) { "request-id" }

  context "with a successful response" do
    before do
      stub_request(
        :get,
        "https://test-teacher-qualifications-api.education.gov.uk/v3/trn-requests?requestId=request-id",
      ).with(
        headers: {
          "Authorization" => "Bearer test-api-key",
          "X-Api-Version" => "Next",
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
        :get,
        "https://test-teacher-qualifications-api.education.gov.uk/v3/trn-requests?requestId=request-id",
      ).with(
        headers: {
          "Authorization" => "Bearer test-api-key",
          "X-Api-Version" => "Next",
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
