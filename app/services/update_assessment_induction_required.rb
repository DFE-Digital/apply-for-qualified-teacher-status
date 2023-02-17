# frozen_string_literal: true

class UpdateAssessmentInductionRequired
  include ServicePattern

  def initialize(assessment:)
    @assessment = assessment
  end

  def call
    assessment.update!(induction_required:)
  end

  private

  attr_reader :assessment

  def induction_required
    passed_months_count < 20
  end

  def passed_months_count
    @passed_months_count ||=
      WorkHistoryDuration.new(work_history_relation:).count_months
  end

  def work_history_relation
    @work_history_relation ||=
      WorkHistory.joins(:reference_request).where(
        reference_requests: {
          passed: true,
          assessment:,
        },
      )
  end
end
