# frozen_string_literal: true

require "rails_helper"

RSpec.describe TRS::V3::QTSRequestParams do
  describe "#call" do
    subject(:call) { described_class.call(application_form:, awarded_at:) }

    let(:teacher) { create(:teacher, email: "teacher@example.com") }

    let(:awarded_at) { Time.zone.now }
    let(:region) { create(:region, :in_country, country_code: "FR") }

    let(:application_form) do
      create(
        :application_form,
        :awarded,
        teacher:,
        created_at: Date.new(2024, 1, 1),
        submitted_at: Date.new(2024, 1, 1),
        date_of_birth: Date.new(1960, 1, 1),
        given_names: "Given",
        family_name: "Family",
        region:,
        teaching_qualification_part_of_degree: true,
      )
    end

    before do
      create(
        :assessment,
        :award,
        recommended_at: Date.new(2024, 1, 7),
        application_form:,
        age_range_min: 7,
        age_range_max: 11,
        subjects: %w[physics french_language],
        induction_required: false,
      )

      create(
        :qualification,
        :completed,
        application_form:,
        start_date: Date.new(1990, 1, 1),
        complete_date: Date.new(1995, 1, 1),
        certificate_date: Date.new(1996, 1, 1),
        title: "Master of Physics and French",
        institution_country_code: region.country.code,
      )
    end

    it do
      expect(subject).to eq(
        {
          routeToProfessionalStatusTypeId:
            "6f27bdeb-d00a-4ef9-b0ea-26498ce64713",
          status: "Approved",
          holdsFrom: awarded_at.to_date.iso8601,
          trainingStartDate: "1990-01-01",
          trainingEndDate: "1995-01-01",
          trainingSubjectReferences: %w[100425 100321],
          trainingAgeSpecialism: {
            type: "Range",
            from: 7,
            to: 11,
          },
          degreeTypeId: nil,
          trainingCountryReference: "FR",
          trainingProviderUkprn: nil,
          isExemptFromInduction: true,
        },
      )
    end

    context "when the applicant has been trained in Scotland" do
      let(:region) { create(:region, :in_country, country_code: "GB-SCT") }

      it do
        expect(subject).to eq(
          {
            routeToProfessionalStatusTypeId:
              "52835b1f-1f2e-4665-abc6-7fb1ef0a80bb",
            status: "Approved",
            holdsFrom: awarded_at.to_date.iso8601,
            trainingStartDate: "1990-01-01",
            trainingEndDate: "1995-01-01",
            trainingSubjectReferences: %w[100425 100321],
            trainingAgeSpecialism: {
              type: "Range",
              from: 7,
              to: 11,
            },
            degreeTypeId: nil,
            trainingCountryReference: "GB-SCT",
            trainingProviderUkprn: nil,
            isExemptFromInduction: true,
          },
        )
      end
    end

    context "when the applicant has been trained in Northern Ireland" do
      let(:region) { create(:region, :in_country, country_code: "GB-NIR") }

      it do
        expect(subject).to eq(
          {
            routeToProfessionalStatusTypeId:
              "3604ef30-8f11-4494-8b52-a2f9c5371e03",
            status: "Approved",
            holdsFrom: awarded_at.to_date.iso8601,
            trainingStartDate: "1990-01-01",
            trainingEndDate: "1995-01-01",
            trainingSubjectReferences: %w[100425 100321],
            trainingAgeSpecialism: {
              type: "Range",
              from: 7,
              to: 11,
            },
            degreeTypeId: nil,
            trainingCountryReference: "GB-NIR",
            trainingProviderUkprn: nil,
            isExemptFromInduction: true,
          },
        )
      end
    end

    context "when the applicant is not exempt from induction" do
      before { application_form.assessment.update!(induction_required: true) }

      it do
        expect(subject).to eq(
          {
            routeToProfessionalStatusTypeId:
              "6f27bdeb-d00a-4ef9-b0ea-26498ce64713",
            status: "Approved",
            holdsFrom: awarded_at.to_date.iso8601,
            trainingStartDate: "1990-01-01",
            trainingEndDate: "1995-01-01",
            trainingSubjectReferences: %w[100425 100321],
            trainingAgeSpecialism: {
              type: "Range",
              from: 7,
              to: 11,
            },
            degreeTypeId: nil,
            trainingCountryReference: "FR",
            trainingProviderUkprn: nil,
            isExemptFromInduction: false,
          },
        )
      end

      context "with the application form created under old regulations" do
        before { application_form.update!(created_at: Date.new(2023, 1, 1)) }

        it do
          expect(subject).to eq(
            {
              routeToProfessionalStatusTypeId:
                "6f27bdeb-d00a-4ef9-b0ea-26498ce64713",
              status: "Approved",
              holdsFrom: awarded_at.to_date.iso8601,
              trainingStartDate: "1990-01-01",
              trainingEndDate: "1995-01-01",
              trainingSubjectReferences: %w[100425 100321],
              trainingAgeSpecialism: {
                type: "Range",
                from: 7,
                to: 11,
              },
              degreeTypeId: nil,
              trainingCountryReference: "FR",
              trainingProviderUkprn: nil,
              isExemptFromInduction: true,
            },
          )
        end
      end
    end
  end
end
