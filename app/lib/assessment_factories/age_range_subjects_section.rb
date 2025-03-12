# frozen_string_literal: true

module AssessmentFactories
  class AgeRangeSubjectsSection
    def initialize(application_form:)
      @application_form = application_form
    end

    def checks
      [
        "qualified_in_mainstream_education",
        (
          if application_form.subject_limited
            "qualified_to_teach_children_11_to_16"
          end
        ),
        (
          if application_form.subject_limited
            "teaching_qualification_subjects_criteria"
          end
        ),
        "age_range_subjects_matches",
      ].compact
    end

    def failure_reasons
      reasons = [
        FailureReasons::NOT_QUALIFIED_TO_TEACH_MAINSTREAM,
        FailureReasons::AGE_RANGE,
      ]

      if suitability_active?
        reasons += [
          FailureReasons::SUITABILITY,
          FailureReasons::SUITABILITY_PREVIOUSLY_DECLINED,
          FailureReasons::FRAUD,
        ]
      end

      reasons
    end

    private

    attr_reader :application_form

    def suitability_active?
      @suitability_active ||= FeatureFlags::FeatureFlag.active?(:suitability)
    end
  end
end
