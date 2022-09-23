module AssessorInterface
  class FurtherInformationRequestsController < BaseController
    def new
      @further_information_request =
        assessment.further_information_requests.build
    end

    def create
      @further_information_request =
        assessment.further_information_requests.create!
      redirect_to [
                    :assessor_interface,
                    application_form,
                    assessment,
                    @further_information_request,
                  ]
    end

    def show
      @further_information_request =
        assessment.further_information_requests.first
    end

    private

    def assessment
      @assessment ||= application_form.assessment
    end

    def application_form
      @application_form ||= ApplicationForm.find(params[:application_form_id])
    end
  end
end
