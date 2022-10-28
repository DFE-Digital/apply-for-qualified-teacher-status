# frozen_string_literal: true

module DQT
  class TRNRequestParams
    include ServicePattern

    def initialize(application_form:)
      @application_form = application_form
      @teacher = application_form.teacher
      @assessment = application_form.assessment
    end

    def call
      {
        firstName: application_form.given_names,
        middleName: nil,
        lastName: application_form.family_name,
        birthDate: application_form.date_of_birth.iso8601,
        emailAddress: teacher.email,
        address: {
        },
        genderCode: "NotAvailable",
        initialTeacherTraining: initial_teacher_training_params,
        qualification: qualification_params,
        teacherType: "OverseasQualifiedTeacher",
        recognitionRoute:
          RecognitionRoute.for_country_code(
            application_form.region.country.code,
          ),
        qtsDate: assessment.recommended_at.iso8601,
        inductionRequired: false,
      }
    end

    private

    attr_reader :application_form, :teacher, :assessment

    def initial_teacher_training_params
      {
        providerUkprn: nil,
        programmeStartDate: teaching_qualification.start_date.iso8601,
        programmeEndDate: teaching_qualification.complete_date.iso8601,
        subject1: subjects.first,
        subject2: subjects.second,
        subject3: subjects.third,
        ageRangeFrom: assessment.age_range_min,
        ageRangeTo: assessment.age_range_max,
        trainingCountryCode:
          CountryCode.for_code(teaching_qualification.institution_country_code),
      }
    end

    def qualification_params
      {
        providerUkprn: nil,
        countryCode:
          CountryCode.for_code(degree_qualification.institution_country_code),
        class: "NotKnown",
        date: degree_qualification.certificate_date.iso8601,
        heQualificationType: "Unknown",
      }
    end

    def subjects
      assessment.subjects.map { |id| Subject.for_id(id.to_sym) }
    end

    def teaching_qualification
      @teaching_qualification ||= application_form.teaching_qualification
    end

    def degree_qualification
      @degree_qualification ||=
        if teaching_qualification.part_of_university_degree?
          teaching_qualification
        else
          application_form.degree_qualifications.first
        end
    end
  end
end
