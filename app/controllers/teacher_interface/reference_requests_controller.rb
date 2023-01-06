# frozen_string_literal: true

module TeacherInterface
  class ReferenceRequestsController < BaseController
    include HandleApplicationFormSection
    include HistoryTrackable

    skip_before_action :authenticate_teacher!
    before_action :load_requested_reference_request, except: :show

    define_history_origin :show
    define_history_reset :show
    define_history_check :edit

    def show
      @reference_request =
        ReferenceRequest.not_expired.find_by!(slug: params[:slug])
      @application_form = reference_request.application_form
      @work_history = reference_request.work_history
    end

    def edit
      @work_history = reference_request.work_history
    end

    def update
      reference_request.received! if reference_request.responses_given?

      redirect_to teacher_interface_reference_request_path
    end

    def edit_dates
      @form =
        ReferenceRequestDatesResponseForm.new(
          reference_request:,
          dates_response: reference_request.dates_response,
        )
    end

    def update_dates
      @form =
        ReferenceRequestDatesResponseForm.new(
          dates_response_form_params.merge(reference_request:),
        )

      handle_application_form_section(
        form: @form,
        if_success_then_redirect: edit_teacher_interface_reference_request_path,
        if_failure_then_render: :edit_dates,
      )
    end

    private

    attr_reader :reference_request

    def load_requested_reference_request
      @reference_request =
        ReferenceRequest.requested.find_by!(slug: params[:slug])
    end

    def dates_response_form_params
      params.require(
        :teacher_interface_reference_request_dates_response_form,
      ).permit(:dates_response)
    end
  end
end
