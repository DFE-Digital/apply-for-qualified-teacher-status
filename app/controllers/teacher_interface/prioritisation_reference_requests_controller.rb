# frozen_string_literal: true

module TeacherInterface
  class PrioritisationReferenceRequestsController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    skip_before_action :authenticate_teacher!
    before_action :load_prioritisation_requested_reference_request,
                  except: :show

    rescue_from ActiveRecord::RecordNotFound, with: :error_not_found

    define_history_origin :show
    define_history_reset :show
    define_history_check :edit

    def show
      @prioritisation_reference_request =
        PrioritisationReferenceRequest
          .joins(:application_form)
          .received
          .or(PrioritisationReferenceRequest.respondable)
          .includes(:work_history, :application_form)
          .find_by!(slug: params[:slug])

      @application_form = prioritisation_reference_request.application_form
      @work_history = prioritisation_reference_request.work_history
    end

    def error_not_found
      render "error_not_found", status: :not_found
    end

    def edit
      @work_history = prioritisation_reference_request.work_history
    end

    def update
      ReceiveRequestable.call(
        requestable: prioritisation_reference_request,
        user: prioritisation_reference_request.work_history.contact_name,
      )

      redirect_to teacher_interface_prioritisation_reference_request_path
    end

    def edit_contact
      @application_form = prioritisation_reference_request.application_form
      @work_history = prioritisation_reference_request.work_history

      @form =
        PrioritisationReferenceRequestContactResponseForm.new(
          prioritisation_reference_request:,
          contact_response: prioritisation_reference_request.contact_response,
          contact_comment: prioritisation_reference_request.contact_comment,
        )
    end

    def update_contact
      @application_form = prioritisation_reference_request.application_form
      @work_history = prioritisation_reference_request.work_history

      @form =
        PrioritisationReferenceRequestContactResponseForm.new(
          contact_response_form_params.merge(prioritisation_reference_request:),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect:
          confirm_applicant_teacher_interface_prioritisation_reference_request_path,
        if_failure_then_render: :edit_contact,
      )
    end

    def edit_confirm_applicant
      @application_form = prioritisation_reference_request.application_form
      @work_history = prioritisation_reference_request.work_history

      @form =
        PrioritisationReferenceRequestConfirmApplicantResponseForm.new(
          prioritisation_reference_request:,
          confirm_applicant_response:
            prioritisation_reference_request.confirm_applicant_response,
          confirm_applicant_comment:
            prioritisation_reference_request.confirm_applicant_comment,
        )
    end

    def update_confirm_applicant
      @application_form = prioritisation_reference_request.application_form
      @work_history = prioritisation_reference_request.work_history

      @form =
        PrioritisationReferenceRequestConfirmApplicantResponseForm.new(
          confirm_applicant_response_form_params.merge(
            prioritisation_reference_request:,
          ),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect:
          edit_teacher_interface_prioritisation_reference_request_path,
        if_failure_then_render: :edit_confirm_applicant,
      )
    end

    private

    attr_reader :prioritisation_reference_request

    def load_prioritisation_requested_reference_request
      @prioritisation_reference_request =
        PrioritisationReferenceRequest
          .joins(:application_form)
          .respondable
          .includes(:work_history, :application_form)
          .find_by!(slug: params[:slug])
    end

    def contact_response_form_params
      params.require(
        :teacher_interface_prioritisation_reference_request_contact_response_form,
      ).permit(:contact_response, :contact_comment)
    end

    def confirm_applicant_response_form_params
      params.require(
        :teacher_interface_prioritisation_reference_request_confirm_applicant_response_form,
      ).permit(:confirm_applicant_response, :confirm_applicant_comment)
    end
  end
end
