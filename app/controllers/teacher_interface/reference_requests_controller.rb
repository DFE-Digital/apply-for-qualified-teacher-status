# frozen_string_literal: true

module TeacherInterface
  class ReferenceRequestsController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    skip_before_action :authenticate_teacher!
    before_action :load_requested_reference_request, except: :show

    rescue_from ActiveRecord::RecordNotFound, with: :error_not_found

    define_history_origin :show
    define_history_reset :show
    define_history_check :edit

    def show
      @reference_request =
        ReferenceRequest
          .joins(:application_form)
          .received
          .or(ReferenceRequest.respondable)
          .includes(:work_history, :application_form)
          .find_by!(slug: params[:slug])

      @application_form = reference_request.application_form
      @work_history = reference_request.work_history
    end

    def error_not_found
      render "error_not_found", status: :not_found
    end

    def edit
      @work_history = reference_request.work_history
    end

    def update
      ReceiveRequestable.call(
        requestable: reference_request,
        user: reference_request.work_history.contact_name,
      )

      redirect_to teacher_interface_reference_request_path
    end

    def edit_contact
      @application_form = reference_request.application_form
      @work_history = reference_request.work_history

      @form =
        ReferenceRequestContactResponseForm.new(
          reference_request:,
          contact_response: reference_request.contact_response,
          contact_name: reference_request.contact_name,
          contact_job: reference_request.contact_job,
          contact_comment: reference_request.contact_comment,
        )
    end

    def update_contact
      @application_form = reference_request.application_form
      @work_history = reference_request.work_history

      @form =
        ReferenceRequestContactResponseForm.new(
          contact_response_form_params.merge(reference_request:),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect:
          dates_teacher_interface_reference_request_path,
        if_failure_then_render: :edit_contact,
      )
    end

    def edit_dates
      @work_history = reference_request.work_history

      @form =
        ReferenceRequestDatesResponseForm.new(
          reference_request:,
          dates_response: reference_request.dates_response,
          dates_comment: reference_request.dates_comment,
        )
    end

    def update_dates
      @work_history = reference_request.work_history

      @form =
        ReferenceRequestDatesResponseForm.new(
          dates_response_form_params.merge(reference_request:),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect:
          hours_teacher_interface_reference_request_path,
        if_failure_then_render: :edit_dates,
      )
    end

    def edit_hours
      @work_history = reference_request.work_history

      @form =
        ReferenceRequestHoursResponseForm.new(
          reference_request:,
          hours_response: reference_request.hours_response,
          hours_comment: reference_request.hours_comment,
        )
    end

    def update_hours
      @work_history = reference_request.work_history

      @form =
        ReferenceRequestHoursResponseForm.new(
          hours_response_form_params.merge(reference_request:),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect:
          children_teacher_interface_reference_request_path,
        if_failure_then_render: :edit_hours,
      )
    end

    def edit_children
      @form =
        ReferenceRequestChildrenResponseForm.new(
          reference_request:,
          children_response: reference_request.children_response,
          children_comment: reference_request.children_comment,
        )
    end

    def update_children
      @form =
        ReferenceRequestChildrenResponseForm.new(
          children_response_form_params.merge(reference_request:),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect:
          lessons_teacher_interface_reference_request_path,
        if_failure_then_render: :edit_children,
      )
    end

    def edit_lessons
      @form =
        ReferenceRequestLessonsResponseForm.new(
          reference_request:,
          lessons_response: reference_request.lessons_response,
          lessons_comment: reference_request.lessons_comment,
        )
    end

    def update_lessons
      @form =
        ReferenceRequestLessonsResponseForm.new(
          lessons_response_form_params.merge(reference_request:),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect:
          reports_teacher_interface_reference_request_path,
        if_failure_then_render: :edit_lessons,
      )
    end

    def edit_reports
      @form =
        ReferenceRequestReportsResponseForm.new(
          reference_request:,
          reports_response: reference_request.reports_response,
          reports_comment: reference_request.reports_comment,
        )
    end

    def update_reports
      @form =
        ReferenceRequestReportsResponseForm.new(
          reports_response_form_params.merge(reference_request:),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect:
          misconduct_teacher_interface_reference_request_path,
        if_failure_then_render: :edit_reports,
      )
    end

    def edit_misconduct
      @form =
        ReferenceRequestMisconductResponseForm.new(
          reference_request:,
          misconduct_response: reference_request.misconduct_response,
          misconduct_comment: reference_request.misconduct_comment,
        )
    end

    def update_misconduct
      @form =
        ReferenceRequestMisconductResponseForm.new(
          misconduct_response_form_params.merge(reference_request:),
        )

      if reference_request.excludes_suitability_and_concerns_question?
        handle_application_form_section(
          form: @form,
          if_success_then_redirect:
            edit_teacher_interface_reference_request_path,
          if_failure_then_render: :edit_misconduct,
        )
      else
        handle_application_form_section(
          form: @form,
          if_success_then_redirect:
            satisfied_teacher_interface_reference_request_path,
          if_failure_then_render: :edit_misconduct,
        )
      end
    end

    def edit_satisfied
      @form =
        ReferenceRequestSatisfiedResponseForm.new(
          reference_request:,
          satisfied_response: reference_request.satisfied_response,
          satisfied_comment: reference_request.satisfied_comment,
        )
    end

    def update_satisfied
      @form =
        ReferenceRequestSatisfiedResponseForm.new(
          satisfied_response_form_params.merge(reference_request:),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect:
          additional_information_teacher_interface_reference_request_path,
        if_failure_then_render: :edit_satisfied,
      )
    end

    def edit_additional_information
      @form =
        ReferenceRequestAdditionalInformationResponseForm.new(
          reference_request:,
          additional_information_response:
            reference_request.additional_information_response,
        )
    end

    def update_additional_information
      @form =
        ReferenceRequestAdditionalInformationResponseForm.new(
          additional_information_response_form_params.merge(reference_request:),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect: edit_teacher_interface_reference_request_path,
        if_failure_then_render: :edit_additional_information,
      )
    end

    private

    attr_reader :reference_request

    def load_requested_reference_request
      @reference_request =
        ReferenceRequest
          .joins(:application_form)
          .respondable
          .includes(:work_history, :application_form)
          .find_by!(slug: params[:slug])
    end

    def contact_response_form_params
      params.require(
        :teacher_interface_reference_request_contact_response_form,
      ).permit(:contact_response, :contact_name, :contact_job, :contact_comment)
    end

    def dates_response_form_params
      params.require(
        :teacher_interface_reference_request_dates_response_form,
      ).permit(:dates_response, :dates_comment)
    end

    def hours_response_form_params
      params.require(
        :teacher_interface_reference_request_hours_response_form,
      ).permit(:hours_response, :hours_comment)
    end

    def children_response_form_params
      params.require(
        :teacher_interface_reference_request_children_response_form,
      ).permit(:children_response, :children_comment)
    end

    def lessons_response_form_params
      params.require(
        :teacher_interface_reference_request_lessons_response_form,
      ).permit(:lessons_response, :lessons_comment)
    end

    def reports_response_form_params
      params.require(
        :teacher_interface_reference_request_reports_response_form,
      ).permit(:reports_response, :reports_comment)
    end

    def misconduct_response_form_params
      params.require(
        :teacher_interface_reference_request_misconduct_response_form,
      ).permit(:misconduct_response, :misconduct_comment)
    end

    def satisfied_response_form_params
      params.require(
        :teacher_interface_reference_request_satisfied_response_form,
      ).permit(:satisfied_response, :satisfied_comment)
    end

    def additional_information_response_form_params
      params.require(
        :teacher_interface_reference_request_additional_information_response_form,
      ).permit(:additional_information_response)
    end
  end
end
