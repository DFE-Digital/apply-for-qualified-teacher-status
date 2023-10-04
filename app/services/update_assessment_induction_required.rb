# frozen_string_literal: true

class UpdateAssessmentInductionRequired
  include ServicePattern

  def initialize(assessment:)
    @assessment = assessment
  end

  def call
    if application_form.needs_work_history
      assessment.update!(induction_required:)
    end
  end

  private

  attr_reader :assessment

  delegate :application_form, to: :assessment

  def induction_required
    passed_months_count < 20
  end

  def passed_months_count
    @passed_months_count ||=
      WorkHistoryDuration.new(work_history_relation:).count_months
  end

  def work_history_relation
    @work_history_relation ||=
      if application_form.reduced_evidence_accepted
        WorkHistory.where(application_form:)
      else
        WorkHistory.joins(:reference_request).where(
          reference_requests: {
            review_passed: true,
            assessment:,
          },
        )
      end
  end
end
