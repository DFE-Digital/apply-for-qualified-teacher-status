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
    "This week #{this_week_start_readable_date} to #{this_week_end_readable_date} (#{email_failures_for_this_week.count})"
  end

  def last_week_tab_name
    "Last week #{last_week_start_readable_date} to #{last_week_end_readable_date} (#{email_failures_for_last_week.count})"
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
      pagy(email_deliveries_with_filter.order(notify_completed_at: :desc))
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

  attr_reader :params
end
