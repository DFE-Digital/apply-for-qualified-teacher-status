# frozen_string_literal: true

module AssessorInterface
  class PreliminaryChecksController < BaseController
    before_action :authorize_assessor

    def edit
      @form = PreliminaryCheckForm.new(assessment: application_form.assessment)
    end

    def update
      @form =
        PreliminaryCheckForm.new(
          form_params.merge(assessment: application_form.assessment),
        )

      if @form.save
        create_note

        redirect_to assessor_interface_application_form_path(application_form)
      else
        render :edit
      end
    end

    private

    def form_params
      params.require(:assessor_interface_preliminary_check_form).permit(
        :preliminary_check_complete,
      )
    end

    def application_form
      @application_form ||=
        ApplicationForm.includes(assessment: :sections).find(
          params[:application_form_id],
        )
    end

    def create_note
      CreatePreliminaryCheckNote.call(application_form:, author: current_staff)
    end
  end
end
