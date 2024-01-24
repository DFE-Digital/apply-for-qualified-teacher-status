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
    !WorkHistoryDuration.new(
      application_form:,
      relation: work_history_relation,
    ).enough_to_skip_induction?
  end

  def work_history_relation
    @work_history_relation ||=
      if application_form.reduced_evidence_accepted
        WorkHistory.where(application_form:)
      else
        WorkHistory
          .joins(:reference_request)
          .where(reference_requests: { verify_passed: true, assessment: })
          .or(
            WorkHistory.where(
              reference_requests: {
                review_passed: true,
                assessment:,
              },
            ),
          )
      end
  end
end
