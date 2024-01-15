# frozen_string_literal: true

class AssignApplicationFormAssessor
  include ServicePattern

  def initialize(application_form:, user:, assessor:)
    @application_form = application_form
    @user = user
    @assessor = assessor
  end

  def call
    return if application_form.assessor == assessor

    ActiveRecord::Base.transaction do
      application_form.update!(assessor:)

      CreateTimelineEvent.call(
        "assessor_assigned",
        application_form:,
        user:,
        assignee: assessor,
      )
    end
  end

  private

  attr_reader :application_form, :user, :assessor
end
