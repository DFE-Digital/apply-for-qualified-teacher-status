# frozen_string_literal: true

class CreateQuickDeclineTimelineEvent
  include ServicePattern

  def initialize(application_form:, user: nil)
    @application_form = application_form
    @user = user || Staff.find_by(support_console_permission: true)
  end

  def call
    unless application_form.requires_preliminary_check &&
             application_form.assessment&.preliminary_check_complete == false &&
             application_form.assessment.sections.map(&:passed).all?(nil)
      return
    end

    TimelineEvent.create!(
      application_form:,
      event_type: :quick_decline,
      creator: user,
    )
  end

  private

  attr_reader :application_form, :user
end
