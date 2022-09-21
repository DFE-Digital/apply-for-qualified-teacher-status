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
end
