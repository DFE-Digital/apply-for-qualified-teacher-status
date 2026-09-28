# frozen_string_literal: true

class AssessorInterface::FeedbackSubmissionsIndexViewObject
  include Pagy::Backend

  def initialize(params:)
    @params = params
  end

  def feedback_submissions_pagy
    feedback_submissions_with_pagy.first
  end

  def feedback_submissions_records
    feedback_submissions_with_pagy.last
  end

  private

  def feedback_submissions_with_pagy
    @feedback_submissions_with_pagy ||=
      pagy(FeedbackSubmission.order(submitted_at: :desc))
  end

  attr_reader :params
end
