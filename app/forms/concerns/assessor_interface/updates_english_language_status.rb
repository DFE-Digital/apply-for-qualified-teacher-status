# frozen_string_literal: true

module AssessorInterface::UpdatesEnglishLanguageStatus
  extend ActiveSupport::Concern

  included do
    attribute :english_language_section_passed, :boolean

    def save
      super && save_english_language_status
    end

    class << self
      def initial_attributes(assessment_section)
        assessment = assessment_section.assessment
        application_form = assessment.application_form

        super.merge(
          english_language_section_passed:
            (
              english_language_section(assessment).passed &&
                application_form.send(self::EXEMPTION_ATTR)
            ),
        )
      end

      def permittable_parameters
        args, kwargs = super
        [args, kwargs.merge(english_language_section_passed: [])]
      end

      def english_language_section(assessment)
        assessment.sections.find_by(key: "english_language_proficiency")
      end
    end

    private

    def save_english_language_status
      return true unless update_english_language_status?

      UpdateAssessmentSection.call(
        assessment_section:
          self.class.english_language_section(assessment_section.assessment),
        user:,
        params: {
          passed: english_language_section_passed,
          selected_failure_reasons: {
          },
        },
      )
    end

    def update_english_language_status?
      english_language_section_passed &&
        application_form.send(self.class::EXEMPTION_ATTR)
    end

    def application_form
      assessment_section.assessment.application_form
    end
  end
end
