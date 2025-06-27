# frozen_string_literal: true

module AssessorInterface
  class PrioritisationWorkHistoryChecksController < BaseController
    def index
      authorize %i[assessor_interface prioritisation_work_history_check]

      @prioritisation_work_history_checks = prioritisation_work_history_checks
      @assessment = prioritisation_work_history_checks.first.assessment
      @application_form = @assessment.application_form

      render layout: "full_from_desktop"
    end

    def edit
      @view_object =
        PrioritisationWorkHistoryCheckViewObject.new(
          prioritisation_work_history_check:,
        )
      @application_form = @view_object.application_form

      @form =
        PrioritisationWorkHistoryCheckForm.new(
          prioritisation_work_history_check:,
          passed: prioritisation_work_history_check.passed,
        )
    end

    def update
      @view_object =
        PrioritisationWorkHistoryCheckViewObject.new(
          prioritisation_work_history_check:,
        )
      @application_form = @view_object.application_form

      @form =
        PrioritisationWorkHistoryCheckForm.new(
          form_params.merge(prioritisation_work_history_check:),
        )

      if @form.save
        redirect_to [
                      :assessor_interface,
                      @application_form,
                      @view_object.assessment,
                      :prioritisation_work_history_checks,
                    ]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def form_params
      unless params[:assessor_interface_prioritisation_work_history_check_form]
        return {}
      end

      params.require(
        :assessor_interface_prioritisation_work_history_check_form,
      ).permit(:passed)
    end

    def prioritisation_work_history_checks
      @prioritisation_work_history_checks ||=
        PrioritisationWorkHistoryCheck
          .joins(assessment: :application_form)
          .includes(:work_history)
          .where(
            assessment_id: params[:assessment_id],
            application_form: {
              reference: params[:application_form_reference],
            },
          )
    end

    def prioritisation_work_history_check
      @prioritisation_work_history_check ||=
        authorize [
                    :assessor_interface,
                    prioritisation_work_history_checks.find(params[:id]),
                  ]
    end
  end
end
