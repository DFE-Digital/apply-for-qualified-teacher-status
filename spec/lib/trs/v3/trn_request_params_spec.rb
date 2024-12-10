# frozen_string_literal: true

require "rails_helper"

RSpec.describe TRS::V3::TRNRequestParams do
  describe "#call" do
    subject(:call) { described_class.call(request_id:, application_form:) }

    let(:teacher) { create(:teacher, email: "teacher@example.com") }
    let(:request_id) { "request-id" }

    let(:application_form) do
      create(
        :application_form,
        :awarded,
        teacher:,
        created_at: Date.new(2024, 1, 1),
        submitted_at: Date.new(2024, 1, 1),
        region: create(:region, :in_country, country_code: "AU"),
        date_of_birth: Date.new(1960, 1, 1),
        given_names: "Given",
        family_name: "Family",
        teaching_qualification_part_of_degree: true,
      )
    end

    it do
      expect(subject).to eq(
        {
          requestId: "request-id",
          person: {
            firstName: "Given",
            lastName: "Family",
            middleName: nil,
            dateOfBirth: "1960-01-01",
            emailAddresses: ["teacher@example.com"],
          },
          identityVerified: true,
          oneLoginUserSubject: nil,
        },
      )
    end

    context "when the teacher has a GOV.UK One Login ID" do
      let(:teacher) do
        create(:teacher, email: "teacher@example.com", gov_one_id: "12345678")
      end

      it do
        expect(subject).to eq(
          {
            requestId: "request-id",
            person: {
              firstName: "Given",
              lastName: "Family",
              middleName: nil,
              dateOfBirth: "1960-01-01",
              emailAddresses: ["teacher@example.com"],
            },
            identityVerified: true,
            oneLoginUserSubject: "12345678",
          },
        )
      end
    end
  end
end
