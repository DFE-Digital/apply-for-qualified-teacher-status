# frozen_string_literal: true

module TeacherInterface
  class FurtherInformationRequestsController < BaseController
    include HistoryTrackable

    before_action :load_view_object
    before_action :ensure_application_form_not_declined

    define_history_origin :show
    define_history_check :edit

    def show
    end

    def edit
      render layout: "full_from_desktop"
    end

    def update
      ReceiveRequestable.call(
        requestable: @view_object.further_information_request,
        user: current_teacher,
      )

      redirect_to %i[teacher_interface application_form]
    end

    private

    def load_view_object
      @view_object =
        FurtherInformationRequestViewObject.new(current_teacher:, params:)
    end

    def ensure_application_form_not_declined
      if @view_object.application_form.declined?
        redirect_to %i[teacher_interface application_form]
      end
    end
  end
end
