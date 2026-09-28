# frozen_string_literal: true

class AssessorInterface::FeedbackSubmissionsController < AssessorInterface::BaseController
  before_action { authorize %i[assessor_interface feedback_submission] }

  def index
    @view_object =
      AssessorInterface::FeedbackSubmissionsIndexViewObject.new(
        params:,
        session:,
      )

    render layout: "full_from_desktop"
  end

  def show
    @feedback_submission = FeedbackSubmission.find(params[:id])
  end

  def apply_filters
    session[:feedback_submissions_filter_params] = extract_filter_params(params)

    redirect_to assessor_interface_feedback_submissions_path
  end

  def clear_filters
    session[:feedback_submissions_filter_params] = {}

    redirect_to assessor_interface_feedback_submissions_path
  end

  private

  def extract_filter_params(params)
    params[:assessor_interface_feedback_submission_filter_form].permit!.to_h
  end
end
