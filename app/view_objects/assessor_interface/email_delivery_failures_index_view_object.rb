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

  private

  def email_deliveries_with_pagy
    @email_deliveries_with_pagy ||=
      pagy(email_deliveries_with_filter.order(notify_completed_at: :desc))
  end

  def email_deliveries_with_filter
    @email_deliveries_with_filter ||=
      if params[:tab] == "last_week"
        email_delivery_failures_for_last_week
      else
        email_delivery_failures_for_this_week
      end
  end

  def email_delivery_failures_for_last_week
    EmailDelivery.failed.where(
      notify_completed_at: 1.week.ago.beginning_of_week..1.week.ago.end_of_week,
    )
  end

  def email_delivery_failures_for_this_week
    EmailDelivery.failed.where(
      notify_completed_at:
        Time.current.beginning_of_week..Time.current.end_of_week,
    )
  end

  attr_reader :params
end
