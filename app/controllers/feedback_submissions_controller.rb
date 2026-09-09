# frozen_string_literal: true

class FeedbackSubmissionsController < ApplicationController
  def new
    @form = FeedbackSubmissionForm.new
  end

  def create
    @form = FeedbackSubmissionForm.new(form_params)

    if @form.save
      redirect_to confirmation_feedback_submissions_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def confirmation
  end

  private

  def form_params
    params.require(:feedback_submission_form).permit(
      :application_status,
      :overall_experience,
      :comment,
    )
  end

  def current_namespace
    current_teacher ? "teacher" : "eligibility"
  end
end
