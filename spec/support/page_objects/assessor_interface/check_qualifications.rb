module PageObjects
  module AssessorInterface
    class QualificationCard < SitePrism::Section
      element :heading, "h2"
      element :title,
              "dl.govuk-summary-list > div:nth-of-type(1) > dd:nth-of-type(1)"
    end

    class CheckQualifications < AssessmentSection
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}/sections/qualifications"

      sections :cards, QualificationCard, ".govuk-summary-list__card"

      def teaching_qualification
        cards&.first
      end
    end
  end
end
