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
          items:
            FurtherInformationRequestItemsFactory.call(
              assessment_sections: assessment.sections,
            ),
        )

      redirect_to [
                    :edit,
                    :assessor_interface,
                    application_form,
                    assessment,
                    @further_information_request,
                  ]
    end

    def show
      @application_form = application_form
      @assessment = assessment
      @further_information_request = further_information_request
    end

    def edit
      @application_form = application_form
      @assessment = assessment
      @further_information_request = further_information_request

      @email_preview =
        FurtherInformationTemplatePreview.with(
          teacher:,
          further_information_request:,
        ).render
    end

    def update
      TeacherMailer
        .with(teacher:, further_information_request:)
        .further_information_requested
        .deliver_later

      further_information_request.requested!

      redirect_to [
                    :assessor_interface,
                    application_form,
                    assessment,
                    further_information_request,
                  ]
    end

    private

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
