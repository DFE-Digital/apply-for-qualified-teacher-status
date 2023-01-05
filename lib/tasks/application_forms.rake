# frozen_string_literal: true

namespace :application_forms do
  desc "Generate a countries CSV file for analytics dashboards."
  task set_awarded_at: :environment do
    ApplicationForm
      .awarded
      .where(awarded_at: nil)
      .each do |application_form|
        timeline_event =
          TimelineEvent.state_changed.find_by(
            application_form:,
            new_state: "awarded",
          )
        application_form.update!(awarded_at: timeline_event.created_at)
      end
  end
end
