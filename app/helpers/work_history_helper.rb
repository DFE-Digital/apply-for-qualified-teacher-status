# frozen_string_literal: true

module WorkHistoryHelper
  def work_history_name(work_history)
    work_history.school_name.presence || work_history.city.presence ||
      work_history.country_name.presence || work_history.job.presence ||
      I18n.t(
        (
          if work_history.current_or_most_recent_teaching_role?
            "application_form.work_history.current_or_most_recent_role"
          else
            "application_form.work_history.previous_role"
          end
        ),
      )
  end

  def work_history_name_and_duration(work_history)
    [
      "#{work_history_name(work_history)} — #{work_history_count_in_months(work_history)}",
      (
        if work_history.current_or_most_recent_teaching_role?
          tag.span("(MOST RECENT)", class: "govuk-!-font-weight-bold")
        end
      ),
    ].compact_blank.join(" ").html_safe
  end

  def work_history_count_in_months(work_history)
    "#{WorkHistoryDuration.for_record(work_history).count_months} months"
  end
end
