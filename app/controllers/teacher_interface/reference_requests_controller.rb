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
    end

    def update
      reference_request.received! if reference_request.responses_given?

      redirect_to teacher_interface_reference_request_path
    end

    private

    attr_reader :reference_request

    def load_requested_reference_request
      @reference_request =
        ReferenceRequest.requested.find_by!(slug: params[:slug])
      @work_history = reference_request.work_history
    end

    private

    attr_reader :reference_request
  end
end
