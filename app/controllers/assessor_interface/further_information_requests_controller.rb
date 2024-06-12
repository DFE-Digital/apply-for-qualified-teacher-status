# frozen_string_literal: true

module AssessorInterface
  class FurtherInformationRequestsController < BaseController
    before_action only: %i[new create] do
      authorize %i[assessor_interface further_information_request]
    end

    before_action except: %i[new create] do
      authorize [:assessor_interface, further_information_request]
    end

    before_action :load_application_form_and_assessment, only: %i[new edit]
    before_action :load_view_object, only: %i[edit update]

    def new
      @further_information_request =
        assessment.further_information_requests.build(
          items:
            FurtherInformationRequestItemsFactory.call(
              assessment_sections: assessment.sections,
            ),
        )
    end

    def create
      RequestFurtherInformation.call(assessment:, user: current_staff)

      redirect_to [:status, :assessor_interface, application_form]
    rescue RequestFurtherInformation::AlreadyExists
      flash[:warning] = "Further information has already been requested."
      render :new, status: :unprocessable_entity
    end

    def edit
      @form =
        RequestableReviewForm.new(
          requestable: view_object.further_information_request,
          user: current_staff,
          passed: view_object.further_information_request.review_passed,
          note: view_object.further_information_request.review_note,
        )
    end

    def update
      @form =
        RequestableReviewForm.new(
          requestable_review_form_params.merge(
            requestable: view_object.further_information_request,
            user: current_staff,
          ),
        )

      if @form.save
        redirect_to [
                      :edit,
                      :assessor_interface,
                      view_object.application_form,
                      view_object.assessment,
                    ]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def load_application_form_and_assessment
      @application_form = application_form
      @assessment = assessment
    end

    def load_view_object
      @view_object = view_object
    end

    def further_information_request
      @further_information_request ||=
        assessment.further_information_requests.find(params[:id])
    end

    def assessment
      @assessment ||= application_form.assessment
    end

    def teacher
      @teacher ||= application_form.teacher
    end

    def application_form
      @application_form ||=
        ApplicationForm.includes(
          assessment: :further_information_requests,
        ).find_by(reference: params[:application_form_reference])
    end

    def view_object
      @view_object ||= FurtherInformationRequestViewObject.new(params:)
    end

    def requestable_review_form_params
      params.require(:assessor_interface_requestable_review_form).permit(
        :passed,
        :note,
      )
    end
  end
end
