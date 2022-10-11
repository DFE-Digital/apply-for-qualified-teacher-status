module AssessorInterface
  class FurtherInformationRequestsController < BaseController
    before_action :load_application_form_and_assessment,
                  only: %i[preview new show edit]
    before_action :load_new_further_information_request, only: %i[preview new]

    def preview
    end

    def new
      @email_preview =
        FurtherInformationTemplatePreview.with(
          teacher:,
          further_information_request: @further_information_request,
        ).render
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
      @view_object = FurtherInformationRequestViewObject.new(params:)
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
  end
end
