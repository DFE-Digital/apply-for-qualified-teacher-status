# frozen_string_literal: true

module AssessorInterface
  class TimelineEventsController < BaseController
    before_action :authorize_assessor

    def index
      @application_form =
        ApplicationForm.find_by!(reference: params[:application_form_reference])

      @timeline_events =
        TimelineEvent
          .includes(:assignee, :assessment_section, :note)
          .where(application_form: @application_form)
          .order(created_at: :desc)
    end
  end
end
