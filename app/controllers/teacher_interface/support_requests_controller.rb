# frozen_string_literal: true

module TeacherInterface
  class SupportRequestsController < BaseController
    include HistoryTrackable

    skip_before_action :authenticate_teacher!

    rescue_from ActiveRecord::RecordNotFound, with: :error_not_found

    def new
      @form = SupportRequestForm.new
    end

    def create
      @form = SupportRequestForm.new(form_params)

      if @form.save(validate: true)
        redirect_to confirmation_teacher_interface_support_requests_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def confirmation
    end

    private

    attr_reader :reference_request

    def form_params
      params.require(:teacher_interface_support_request_form).permit(
        :name,
        :email,
        :comment,
        :category_type,
        :application_reference,
        :application_enquiry_type,
      )
    end
  end
end
