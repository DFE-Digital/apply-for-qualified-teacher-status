# frozen_string_literal: true

require "rails_helper"

RSpec.describe TRS::Client::V3::UpdateQTSRequest do
  subject(:call) { described_class.call(application_form:) }

  let(:application_form) { create(:application_form, teacher:) }
  let(:teacher) { create(:teacher, trn: "12345") }

  before do
    allow(TRS::V3::QTSRequestParams).to receive(:call).with(
      application_form:,
    ).and_return("body")
  end

  context "with a successful response" do
    before do
      stub_request(
        :put,
        "https://test-teacher-qualifications-api.education.gov.uk/v3/persons/#{teacher.trn}/professional-statuses/#{application_form.reference}",
      ).with(
        body: "body",
        headers: {
          "X-Api-Version" => "Next",
          "Authorization" => "Bearer test-api-key",
          "Content-Type" => "application/json",
        },
      ).to_return(
        status: 200,
        body: "",
        headers: {
          "Content-Type" => "application/json",
        },
      )
    end

    it { expect(subject).to be_nil }
  end

  context "with a failure response" do
    before do
      stub_request(
        :put,
        "https://test-teacher-qualifications-api.education.gov.uk/v3/persons/#{teacher.trn}/professional-statuses/#{application_form.reference}",
      ).with(
        body: "body",
        headers: {
          "X-Api-Version" => "Next",
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
