# frozen_string_literal: true

class AssignApplicationFormReviewer
  include ServicePattern

  def initialize(application_form:, user:, reviewer:)
    @application_form = application_form
    @user = user
    @reviewer = reviewer
  end

  def call
    return if application_form.reviewer == reviewer

    ActiveRecord::Base.transaction do
      application_form.update!(reviewer:)

      CreateTimelineEvent.call(
        "reviewer_assigned",
        application_form:,
        user:,
        assignee: reviewer,
      )
    end
  end

  private

  attr_reader :application_form, :user, :reviewer
end
