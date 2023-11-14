module WorkHistoryHelper
  def work_history_title(work_history)
    work_history.school_name.presence || work_history.city.presence ||
      work_history.country_name.presence || work_history.job.presence ||
      I18n.t(
        (
          if work_history.current_or_most_recent_role?
            "application_form.work_history.current_or_most_recent_role"
          else
            "application_form.work_history.previous_role"
          end
        ),
      )
  end

  def work_history_name_and_duration(work_history, most_recent: false)
    months = WorkHistoryDuration.for_record(work_history).count_months

    result = "#{work_history.school_name} (#{months} months)"
    result.concat(" ", most_recent_tag) if most_recent
    result.html_safe
  end

  def most_recent_tag
    tag.span("MOST RECENT", class: "govuk-!-font-weight-bold")
  end
end
