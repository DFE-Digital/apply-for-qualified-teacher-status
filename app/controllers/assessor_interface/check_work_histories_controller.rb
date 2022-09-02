module AssessorInterface
  class CheckWorkHistoriesController < BaseController
    def show
      @application_form =
        ApplicationForm.includes(:work_histories).find(
          params[:application_form_id]
        )
      @work_histories = @application_form.work_histories.ordered
    end
  end
end
