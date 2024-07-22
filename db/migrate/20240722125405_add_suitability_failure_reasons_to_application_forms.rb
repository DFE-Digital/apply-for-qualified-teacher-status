# frozen_string_literal: true

class AddSuitabilityFailureReasonsToApplicationForms < ActiveRecord::Migration[
  7.1
]
  def change
    AssessmentSection
      .not_preliminary
      .joins(:application_form)
      .where(
        application_form: {
          stage: %w[pre_assessment not_started assessment],
        },
      )
      .find_each do |assessment_section|
        assessment_section.update!(
          failure_reasons:
            (
              assessment_section.failure_reasons +
                [
                  FailureReasons::SUITABILITY,
                  FailureReasons::SUITABILITY_PREVIOUSLY_DECLINED,
                  FailureReasons::FRAUD,
                ]
            ).uniq,
        )
      end
  end
end
