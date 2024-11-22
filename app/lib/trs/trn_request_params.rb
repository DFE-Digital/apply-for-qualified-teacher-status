# frozen_string_literal: true

module TRS
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
        identityVerified: true,
        oneLoginUserSubject: teacher.gov_one_id,
        address: {
        },
        genderCode: "NotAvailable",
        initialTeacherTraining: initial_teacher_training_params,
        qualification: qualification_params,
        teacherType: "OverseasQualifiedTeacher",
        recognitionRoute:
          RecognitionRoute.for_country_code(
            application_form.region.country.code,
            under_old_regulations:
              application_form.created_under_old_regulations?,
          ),
        qtsDate: qts_decision_at.to_date.iso8601,
        inductionRequired: induction_required,
        underNewOverseasRegulations:
          !application_form.created_under_old_regulations?,
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
      assessment.subjects.map { |value| Subject.for(value) }
    end

    def teaching_qualification
      @teaching_qualification ||= application_form.teaching_qualification
    end

    def degree_qualification
      @degree_qualification ||= application_form.bachelor_degree_qualification
    end

    def qts_decision_at
      if application_form.created_under_old_regulations?
        application_form.submitted_at
      else
        application_form.assessment.recommended_at
      end
    end

    def induction_required
      return false if application_form.created_under_old_regulations?

      assessment.induction_required
    end
  end
end
