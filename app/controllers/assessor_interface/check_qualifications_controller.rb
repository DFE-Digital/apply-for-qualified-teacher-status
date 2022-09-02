module AssessorInterface
  class CheckQualificationsController < BaseController
    def show
      @application_form =
        ApplicationForm.includes(:qualifications).find(
          params[:application_form_id]
        )
      @qualifications = @application_form.qualifications.ordered
    end
  end
end
