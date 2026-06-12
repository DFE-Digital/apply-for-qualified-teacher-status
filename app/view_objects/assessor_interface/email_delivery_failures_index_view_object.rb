# frozen_string_literal: true

class AssessorInterface::EmailDeliveryFailuresIndexViewObject
  include ActionView::Helpers::FormOptionsHelper
  include Pagy::Backend

  def initialize(params:)
    @params = params
  end

  def email_deliveries_pagy
    email_deliveries_with_pagy.first
  end

  def email_deliveries_records
    email_deliveries_with_pagy.last
  end

  def this_week_tab_name
    "This week #{this_week_start_readable_date} to #{this_week_end_readable_date} (#{this_week_failures_count})"
  end

  def last_week_tab_name
    "Last week #{last_week_start_readable_date} to #{last_week_end_readable_date} (#{last_week_failures_count})"
  end

  def last_week_delivery_stats_statement
    "#{last_week_failures_count} out of #{last_week_total_count} emails " \
      "failed to send between #{last_week_start_readable_date} and #{last_week_end_readable_date}."
  end

  private

  def this_week_start_at
    Time.current.beginning_of_week
  end

  def this_week_start_readable_date
    this_week_start_at.to_date.to_fs(:short)
  end

  def this_week_end_at
    Time.current.end_of_week
  end

  def this_week_end_readable_date
    this_week_end_at.to_date.to_fs(:short)
  end

  def last_week_start_at
    1.week.ago.beginning_of_week
  end

  def last_week_start_readable_date
    last_week_start_at.to_date.to_fs(:short)
  end

  def last_week_end_at
    1.week.ago.end_of_week
  end

  def last_week_end_readable_date
    last_week_end_at.to_date.to_fs(:short)
  end

  def email_deliveries_with_pagy
    @email_deliveries_with_pagy ||=
      pagy(
        email_deliveries_with_filter.preload(application_form: :assessor).order(
          notify_completed_at: :desc,
        ),
        count: active_tab_failures_count,
        limit: 100,
      )
  end

  def email_deliveries_with_filter
    @email_deliveries_with_filter ||=
      if params[:tab] == "last_week"
        email_failures_for_last_week
      else
        email_failures_for_this_week
      end
  end

  def email_failures_for_last_week
    @email_failures_for_last_week ||=
      EmailDelivery.failed.where(
        notify_completed_at: last_week_start_at..last_week_end_at,
      )
  end

  def email_failures_for_this_week
    @email_failures_for_this_week ||=
      EmailDelivery.failed.where(
        notify_completed_at: this_week_start_at..this_week_end_at,
      )
  end

  def this_week_failures_count
    @this_week_failures_count ||= email_failures_for_this_week.count
  end

  def last_week_failures_count
    @last_week_failures_count ||= email_failures_for_last_week.count
  end

  def last_week_total_count
    @last_week_total_count ||=
      EmailDelivery.where(
        notify_completed_at: last_week_start_at..last_week_end_at,
      ).count
  end

  def active_tab_failures_count
    if params[:tab] == "last_week"
      last_week_failures_count
    else
      this_week_failures_count
    end
  end

  attr_reader :params
end
