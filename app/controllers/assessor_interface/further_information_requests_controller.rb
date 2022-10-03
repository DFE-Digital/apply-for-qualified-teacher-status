module AssessorInterface
  class FurtherInformationRequestsController < BaseController
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
      @further_information_request =
        assessment.further_information_requests.create!(
          further_information_request_params.merge(
            items:
              FurtherInformationRequestItemsFactory.call(
                assessment_sections: assessment.sections,
              ),
          ),
        )

      redirect_to [
                    :assessor_interface,
                    application_form,
                    assessment,
                    @further_information_request,
                  ]
    end

    def show
      @further_information_request =
        assessment.further_information_requests.find(params[:id])
      @email_preview =
        FurtherInformationTemplatePreview.with(
          teacher:,
          further_information_request: @further_information_request,
        ).render
    end

    private

    def assessment
      @assessment ||= application_form.assessment
    end

    def application_form
      @application_form ||= ApplicationForm.find(params[:application_form_id])
    end

    def teacher
      application_form.teacher
    end

    def further_information_request_params
      params.require(:further_information_request).permit(:email_content)
    end
  end
end
