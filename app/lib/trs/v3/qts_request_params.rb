# frozen_string_literal: true

module TRS
  module V3
    class QTSRequestParams
      include ServicePattern

      AWARDED_QTS_STATUS = "Holds"

      SCOTLAND_RECOGNITION_ROUTE_TYPE_ID =
        "52835b1f-1f2e-4665-abc6-7fb1ef0a80bb"
      NORTHERN_IRELAND_RECOGNITION_ROUTE_TYPE_ID =
        "3604ef30-8f11-4494-8b52-a2f9c5371e03"
      ALL_RECOGNITION_ROUTE_TYPE_ID = "6f27bdeb-d00a-4ef9-b0ea-26498ce64713"

      def initialize(application_form:, awarded_at:)
        @application_form = application_form
        @awarded_at = awarded_at
        @teacher = application_form.teacher
        @assessment = application_form.assessment
      end

      def call
        {
          routeToProfessionalStatusTypeId: route_type_id,
          status: AWARDED_QTS_STATUS,
          awardedDate: awarded_at.to_date.iso8601,
          trainingStartDate: teaching_qualification.start_date.iso8601,
          trainingEndDate: teaching_qualification.complete_date.iso8601,
          trainingSubjectReferences: subjects,
          trainingAgeSpecialism: age_range,
          degreeTypeId: nil,
          trainingCountryReference:
            teaching_qualification.institution_country_code,
          trainingProviderUkprn: nil,
          isExemptFromInduction: exempt_from_induction,
        }
      end

      private

      attr_reader :application_form, :teacher, :assessment, :awarded_at

      def teaching_qualification
        @teaching_qualification ||= application_form.teaching_qualification
      end

      def subjects
        assessment.subjects.map { |value| Subject.for(value) }
      end

      def age_range
        {
          type: "Range",
          from: assessment.age_range_min,
          to: assessment.age_range_max,
        }
      end

      def exempt_from_induction
        return true if application_form.created_under_old_regulations?

        !assessment.induction_required
      end

      def route_type_id
        if ::CountryCode.scotland?(country_code)
          SCOTLAND_RECOGNITION_ROUTE_TYPE_ID
        elsif ::CountryCode.northern_ireland?(country_code)
          NORTHERN_IRELAND_RECOGNITION_ROUTE_TYPE_ID
        else
          ALL_RECOGNITION_ROUTE_TYPE_ID
        end
      end

      def country_code
        @country_code ||= application_form.region.country.code
      end
    end
  end
end
