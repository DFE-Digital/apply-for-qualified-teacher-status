# frozen_string_literal: true

module TRS
  module V3
    class QTSRequestParams
      include ServicePattern

      def initialize(application_form:)
        @application_form = application_form
        @teacher = application_form.teacher
        @assessment = application_form.assessment
      end

      def call
        {
          routeType: route_type,
          startDate: teaching_qualification.start_date.iso8601,
          endDate: teaching_qualification.complete_date.iso8601,
          subjects:,
          ageRange: age_range,
          degreeType: nil,
          trainingCountryCode:
            CountryCode.for_code(
              teaching_qualification.institution_country_code,
            ),
          providerUkprn: nil,
          routeStatus: "Awarded", # TODO: TBC
          exemptFromInduction: exempt_from_induction,
          inductionExemptionReasons: induction_exemption_reasons,
        }
      end

      private

      attr_reader :application_form, :teacher, :assessment

      def teaching_qualification
        @teaching_qualification ||= application_form.teaching_qualification
      end

      def subjects
        assessment.subjects.map { |value| Subject.for(value) }
      end

      def age_range
        { from: assessment.age_range_min, to: assessment.age_range_max }
      end

      def exempt_from_induction
        return true if application_form.created_under_old_regulations?

        !assessment.induction_required
      end

      def induction_exemption_reasons
        # TODO: List of potential reasons to be provided.
        # This must be provided if exemptFromInduction is true
      end

      def route_type
        # TODO: The value returned will be either an enum or GUID. TBD
        if CountryCode.scotland?(country_code)
          "Scotland R"
        elsif CountryCode.northern_ireland?(country_code)
          "NI R"
        else
          "Apply for QTS"
        end
      end

      def country_code
        @country_code ||= application_form.region.country.code
      end
    end
  end
end
