module PageObjects
  module AssessorInterface
    class QualificationCard < SitePrism::Section
      element :heading, "h2"
      element :title,
              "dl.govuk-summary-list > div:nth-of-type(1) > dd:nth-of-type(1)"
    end

    class CheckQualifications < AssessmentSection
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}/sections/{section_id}"

      sections :cards, QualificationCard, ".govuk-summary-card"

      section :exemption_form, "form" do
        element :english_language_exempt,
                "#assessor-interface-assessment-section-form-english-language-section-passed-true-field",
                visible: false
      end

      def teaching_qualification
        cards&.first
      end
    end
  end
end
