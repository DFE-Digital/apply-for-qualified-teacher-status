# frozen_string_literal: true

class AssessorInterface::ServiceLevelAgreementTotalsViewObject
  def initialize(params:)
    @params = params
  end

  def sla_counts
    {
      "10" => Filters::SLA::TenDay,
      "40" => Filters::SLA::FortyDay,
      "80" => Filters::SLA::EightyDay,
    }.transform_values { |sla_base_filter| counts_for(sla_base_filter) }
  end

  private

  attr_reader :params

  def counts_for(sla_base_filter)
    scope =
      Filters::SLA::CountryGroupings.apply(
        scope: sla_base_filter.apply(scope: ApplicationForm, params: {}),
        params:,
      )

    {
      nearing:
        scope.where(
          working_days_between_submitted_and_today:
            sla_base_filter::WORKING_DAYS_NEARING_FROM...sla_base_filter::WORKING_DAYS_BREACHED_FROM,
        ).count,
      breached:
        scope.where(
          working_days_between_submitted_and_today:
            sla_base_filter::WORKING_DAYS_BREACHED_FROM..,
        ).count,
    }
  end
end
