# frozen_string_literal: true

require "rails_helper"

RSpec.describe TRS::TRNRequestParams do
  describe "#call" do
    subject(:call) { described_class.call(application_form:) }

    let(:teacher) { create(:teacher, email: "teacher@example.com") }

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

    before do
      create(
        :assessment,
        :award,
        recommended_at: Date.new(2024, 1, 7),
        application_form:,
        age_range_min: 7,
        age_range_max: 11,
        subjects: %w[physics french_language],
        induction_required: true,
      )

      create(
        :qualification,
        :completed,
        application_form:,
        start_date: Date.new(1990, 1, 1),
        complete_date: Date.new(1995, 1, 1),
        certificate_date: Date.new(1996, 1, 1),
        title: "Master of Physics and French",
        institution_country_code: "FR",
      )
    end

    it do
      expect(subject).to eq(
        {
          address: {
          },
          birthDate: "1960-01-01",
          emailAddress: "teacher@example.com",
          firstName: "Given",
          genderCode: "NotAvailable",
          inductionRequired: true,
          identityVerified: true,
          oneLoginUserSubject: nil,
          initialTeacherTraining: {
            ageRangeFrom: 7,
            ageRangeTo: 11,
            programmeStartDate: "1990-01-01",
            programmeEndDate: "1995-01-01",
            providerUkprn: nil,
            subject1: "100425",
            subject2: "100321",
            subject3: nil,
            trainingCountryCode: "FR",
          },
          lastName: "Family",
          middleName: nil,
          qtsDate: "2024-01-07",
          qualification: {
            class: "NotKnown",
            countryCode: "FR",
            date: "1996-01-01",
            heQualificationType: "Unknown",
            providerUkprn: nil,
          },
          recognitionRoute: "OverseasTrainedTeachers",
          teacherType: "OverseasQualifiedTeacher",
          underNewOverseasRegulations: true,
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
            address: {
            },
            birthDate: "1960-01-01",
            emailAddress: "teacher@example.com",
            firstName: "Given",
            genderCode: "NotAvailable",
            inductionRequired: true,
            identityVerified: true,
            oneLoginUserSubject: "12345678",
            initialTeacherTraining: {
              ageRangeFrom: 7,
              ageRangeTo: 11,
              programmeStartDate: "1990-01-01",
              programmeEndDate: "1995-01-01",
              providerUkprn: nil,
              subject1: "100425",
              subject2: "100321",
              subject3: nil,
              trainingCountryCode: "FR",
            },
            lastName: "Family",
            middleName: nil,
            qtsDate: "2024-01-07",
            qualification: {
              class: "NotKnown",
              countryCode: "FR",
              date: "1996-01-01",
              heQualificationType: "Unknown",
              providerUkprn: nil,
            },
            recognitionRoute: "OverseasTrainedTeachers",
            teacherType: "OverseasQualifiedTeacher",
            underNewOverseasRegulations: true,
          },
        )
      end
    end
  end
end
