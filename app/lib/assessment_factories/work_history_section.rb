# frozen_string_literal: true

module AssessmentFactories
  class WorkHistorySection
    def initialize(application_form:)
      @application_form = application_form
    end

    def checks
      %i[verify_school_details work_history_references]
    end

    def failure_reasons
      reasons = [
        FailureReasons::WORK_HISTORY_BREAK,
        FailureReasons::SCHOOL_DETAILS_CANNOT_BE_VERIFIED,
        FailureReasons::UNRECOGNISED_REFERENCES,
        FailureReasons::WORK_HISTORY_DURATION,
        FailureReasons::WORK_HISTORY_INFORMATION,
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
