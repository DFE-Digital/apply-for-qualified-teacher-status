module AssessorInterface
  class TimelineEventsController < BaseController
    def index
      @application_form = ApplicationForm.find(params[:application_form_id])

      @timeline_events =
        TimelineEvent
          .includes(:assignee, :assessment_section, :note)
          .where(application_form: @application_form)
          .order(created_at: :desc)
    end
  end
end
