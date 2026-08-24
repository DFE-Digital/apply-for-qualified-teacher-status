# frozen_string_literal: true

class Filters::SLA::BreachStatuses < Filters::Base
  def apply
    return scope if breach_statuses.blank?

    nearing = breach_statuses.include?("nearing")
    breached = breach_statuses.include?("breached")

    working_days_range =
      if nearing && breached
        nearing_working_days..
      elsif nearing
        nearing_working_days...breached_working_days
      elsif breached
        breached_working_days..
      end

    return scope if working_days_range.nil?

    scope.where(working_days_between_submitted_and_today: working_days_range)
  end

  private

  def breached_working_days
    sla_base_filter_class::WORKING_DAYS_BREACHED_FROM
  end

  def nearing_working_days
    sla_base_filter_class::WORKING_DAYS_NEARING_FROM
  end

  def breach_statuses
    params[:breach_statuses]
  end

  def sla_base_filter_class
    if params[:sla] == "80"
      Filters::SLA::EightyDay
    elsif params[:sla] == "40"
      Filters::SLA::FortyDay
    else
      Filters::SLA::TenDay
    end
  end

  def sla
    params[:sla]
  end
end
