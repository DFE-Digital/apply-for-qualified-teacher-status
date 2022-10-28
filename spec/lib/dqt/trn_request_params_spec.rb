# frozen_string_literal: true

require "rails_helper"

RSpec.describe DQT::TRNRequestParams do
  describe "#call" do
    let(:teacher) { create(:teacher, :confirmed, email: "teacher@example.com") }

    let(:application_form) do
      create(
        :application_form,
        teacher:,
        region: create(:region, country: create(:country, code: "AU")),
        date_of_birth: Date.new(1960, 1, 1),
        given_names: "Given",
        family_name: "Family",
      )
    end

    before do
      create(
        :assessment,
        :award,
        application_form:,
        recommended_at: Date.new(2020, 1, 1),
        age_range_min: 7,
        age_range_max: 11,
        subjects: %w[physics french_language],
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

    subject(:call) { described_class.call(application_form:) }

    it do
      is_expected.to eq(
        {
          address: {
          },
          birthDate: "1960-01-01",
          emailAddress: "teacher@example.com",
          firstName: "Given",
          genderCode: "NotAvailable",
          inductionRequired: false,
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
          qtsDate: "2020-01-01",
          qualification: {
            class: "NotKnown",
            countryCode: "FR",
            date: "1996-01-01",
            heQualificationType: "Unknown",
            providerUkprn: nil,
          },
          recognitionRoute: "OverseasTrainedTeachers",
          teacherType: "OverseasQualifiedTeacher",
        },
      )
    end
  end
end
