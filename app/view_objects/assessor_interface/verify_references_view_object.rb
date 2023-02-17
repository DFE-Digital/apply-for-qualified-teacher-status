# frozen_string_literal: true

class AssessorInterface::VerifyReferencesViewObject
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::DateHelper

  attr_reader :assessment

  def initialize(assessment:)
    @assessment = assessment
  end

  def reference_requests
    @reference_requests ||=
      assessment
        .reference_requests
        .includes(:work_history)
        .order("work_histories.start_date")
        .to_a
  end

  def name_and_duration(work_history, most_recent: false)
    months =
      WorkHistoryDuration.new(work_history_record: work_history).count_months

    result = "#{work_history.school_name} (#{months} months)"
    result.concat(" ", most_recent_tag) if most_recent
    result.html_safe
  end

  delegate :application_form, to: :assessment

  def most_recent_tag
    tag.span("MOST RECENT", class: "govuk-!-font-weight-bold")
  end
end
