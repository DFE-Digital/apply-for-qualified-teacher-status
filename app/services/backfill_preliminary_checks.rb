# frozen_string_literal: true

class BackfillPreliminaryChecks
  include ServicePattern

  def initialize(user:)
    @user = user
  end

  def call
    applications_forms.find_each do |application_form|
      assessment = application_form.assessment

      application_form.update!(requires_preliminary_check: true)

      unless assessment.sections.preliminary.exists?
        assessment.sections +=
          PreliminaryAssessmentSectionsFactory.call(application_form:)
        assessment.save!
      end

      ApplicationFormStatusUpdater.call(application_form:, user:)
    end

    applications_forms.count
  end

  private

  attr_reader :user

  def regions
    @regions ||= Region.where(requires_preliminary_check: true)
  end

  def applications_forms
    @applications_forms ||=
      ApplicationForm
        .includes(assessment: :sections)
        .where(
          region: regions,
          assessor: nil,
          requires_preliminary_check: false,
        )
        .merge(
          ApplicationForm
            .where.not(submitted_at: nil)
            .or(
              ApplicationForm.pre_assessment_stage.where(
                "'waiting_on_lops' = ANY (statuses)",
                teaching_authority_provides_written_statement: true,
              ),
            ),
        )
  end
end
