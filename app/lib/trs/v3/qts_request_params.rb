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
          routeType: "", # TODO: Something like "Apply for QTS" TBC.
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
    end
  end
end
