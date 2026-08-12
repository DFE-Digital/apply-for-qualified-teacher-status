# frozen_string_literal: true

class Filters::SLA::BreachStatuses < Filters::Base
  def apply
    return scope if breach_statuses.nil?

    if breach_statuses.include?("nearing") &&
         breach_statuses.include?("breached")
      scope.where(
        "working_days_between_submitted_and_today >= ?",
        nearing_working_days,
      )
    elsif breach_statuses.include?("nearing")
      scope.where(
        "working_days_between_submitted_and_today >= ? and working_days_between_submitted_and_today < ?",
        nearing_working_days,
        breached_working_days,
      )
    elsif breach_statuses.include?("breached")
      scope.where(
        "working_days_between_submitted_and_today >= ?",
        breached_working_days,
      )
    else
      scope
    end
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
      Filters::SLA::FourtyDay
    else
      Filters::SLA::TenDay
    end
  end

  def sla
    params[:sla]
  end
end
