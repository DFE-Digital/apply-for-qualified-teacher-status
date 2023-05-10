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
        update_application_form_status

        if @form.preliminary_check_complete
          notify_teacher
          create_note
          unassign_assessor!
        end

        redirect_to assessor_interface_application_form_path(application_form)
      else
        render :edit, status: :unprocessable_entity
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

    def notify_teacher
      if application_form.teaching_authority_provides_written_statement
        TeacherMailer
          .with(teacher: application_form.teacher)
          .initial_checks_passed
          .deliver_later
      end
    end

    def update_application_form_status
      ApplicationFormStatusUpdater.call(application_form:, user: current_staff)
    end

    def unassign_assessor!
      AssignApplicationFormAssessor.call(
        application_form:,
        user: current_staff,
        assessor: nil,
      )
    end
  end
end
