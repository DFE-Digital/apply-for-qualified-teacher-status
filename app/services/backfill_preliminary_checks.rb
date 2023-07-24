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
    @regions ||= Region.requires_preliminary_check
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
          ApplicationForm.submitted.or(
            ApplicationForm.waiting_on.where(
              teaching_authority_provides_written_statement: true,
              waiting_on_professional_standing: true,
            ),
          ),
        )
  end
end
