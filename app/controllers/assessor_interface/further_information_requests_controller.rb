module AssessorInterface
  class FurtherInformationRequestsController < BaseController
    before_action :load_application_form_and_assessment,
                  only: %i[preview new show edit]
    before_action :load_new_further_information_request, only: %i[preview new]
    before_action :load_view_object, only: %i[edit update]

    def preview
    end

    def new
    end

    def create
      further_information_request =
        CreateFurtherInformationRequest.call(assessment:, user: current_staff)

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
      @further_information_request_form =
        FurtherInformationRequestForm.new(
          further_information_request: view_object.further_information_request,
          user: current_staff,
          passed: view_object.further_information_request.passed,
          failure_reason:
            view_object.further_information_request.failure_reason,
        )
    end

    def update
      @further_information_request_form =
        FurtherInformationRequestForm.new(
          further_information_request_form.merge(
            further_information_request:
              view_object.further_information_request,
            user: current_staff,
          ),
        )

      if @further_information_request_form.save
        redirect_to [:assessor_interface, view_object.application_form]
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

    def further_information_request_form
      params.require(
        :assessor_interface_further_information_request_form,
      ).permit(:passed, :failure_reason)
    end
  end
end
