module AssessorInterface
  class CheckProfessionalStandingsController < BaseController
    def show
      @application_form = ApplicationForm.find(params[:application_form_id])
    end
  end
end
