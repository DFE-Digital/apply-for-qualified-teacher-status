# frozen_string_literal: true

require "rails_helper"

RSpec.describe DQT::Client::FindTeachers do
  subject(:call) { described_class.call(application_form:) }

  let(:application_form) do
    create(:application_form, :submitted, :with_personal_information)
  end
  let(:request_params) do
    {
      findBy: "LastNameAndDateOfBirth",
      dateOfBirth: application_form.date_of_birth.iso8601.to_s,
      lastName: application_form.family_name,
    }
  end

  context "with a successful response" do
    let(:result) do
      {
        dateOfBirth: application_form.date_of_birth.iso8601.to_s,
        firstName: application_form.given_names.split(" ").first,
        lastName: application_form.family_name,
        trn: "1234567",
      }
    end

    before do
      stub_request(
        :get,
        "https://test-teacher-qualifications-api.education.gov.uk/v3/teachers?#{request_params.to_query}",
      ).with(headers: { "Authorization" => "Bearer test-api-key" }).to_return(
        status: 200,
        body: { results: [result] }.to_json,
        headers: {
          "Content-Type" => "application/json",
        },
      )
    end

    it do
      expect(subject).to eq(
        [
          {
            date_of_birth: application_form.date_of_birth.iso8601.to_s,
            first_name: application_form.given_names.split(" ").first,
            last_name: application_form.family_name,
            trn: "1234567",
          },
        ],
      )
    end
  end

  context "with an error response" do
    before do
      stub_request(
        :get,
        "https://test-teacher-qualifications-api.education.gov.uk/v3/teachers?#{request_params.to_query}",
      ).with(headers: { "Authorization" => "Bearer test-api-key" }).to_return(
        status: 500,
        headers: {
          "Content-Type" => "application/json",
        },
      )
    end

    it { is_expected.to eq([]) }
  end
end
