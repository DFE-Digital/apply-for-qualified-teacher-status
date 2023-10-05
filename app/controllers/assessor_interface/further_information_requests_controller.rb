# frozen_string_literal: true

module AssessorInterface
  class FurtherInformationRequestsController < BaseController
    before_action :authorize_assessor, except: %i[preview edit]
    before_action :load_application_form_and_assessment,
                  only: %i[preview new show edit]
    before_action :load_new_further_information_request, only: %i[preview new]
    before_action :load_view_object, only: %i[edit update]

    def preview
      authorize :assessor, :show?
    end

    def new
    end

    def create
      further_information_request =
        ActiveRecord::Base.transaction do
          assessment.request_further_information!
          CreateFurtherInformationRequest.call(assessment:, user: current_staff)
        end

      redirect_to [
                    :assessor_interface,
                    application_form,
                    assessment,
                    further_information_request,
                  ]
    end

    def show
      @further_information_request = further_information_request
    end

    def edit
      authorize :assessor, :show?

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

    def load_new_further_information_request
      @further_information_request =
        assessment.further_information_requests.build(
          items:
            FurtherInformationRequestItemsFactory.call(
              assessment_sections: assessment.sections,
            ),
        )
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
        ).find(params[:application_form_id])
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
