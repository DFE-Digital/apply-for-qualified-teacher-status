module TeacherInterface
  class FurtherInformationRequestsController < BaseController
    before_action :load_application_form

    def show
      @further_information_request = further_information_request
    end

    private

    def further_information_request
      @further_information_request ||=
        FurtherInformationRequest
          .joins(:assessment)
          .requested
          .where(assessments: { application_form: })
          .find(params[:id])
    end
  end
end
