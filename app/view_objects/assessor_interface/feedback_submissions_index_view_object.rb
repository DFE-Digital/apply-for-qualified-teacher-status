# frozen_string_literal: true

class AssessorInterface::FeedbackSubmissionsIndexViewObject
  include Pagy::Backend

  def initialize(params:, session:)
    @params = params
    @session = session
  end

  def feedback_submissions_pagy
    feedback_submissions_with_pagy.first
  end

  def feedback_submissions_records
    feedback_submissions_with_pagy.last
  end

  def feedback_submissions_scope
    ::Filters::SubmittedAt.apply(
      scope: FeedbackSubmission.all,
      params: filter_params,
    ).order(submitted_at: :desc)
  end

  def filter_form
    @filter_form ||=
      AssessorInterface::FeedbackSubmissionFilterForm.new(filter_params)
  end

  private

  def feedback_submissions_with_pagy
    @feedback_submissions_with_pagy ||= pagy(feedback_submissions_scope)
  end

  def filter_params
    (session[:feedback_submissions_filter_params] || {}).with_indifferent_access
  end

  attr_reader :params, :session
end
