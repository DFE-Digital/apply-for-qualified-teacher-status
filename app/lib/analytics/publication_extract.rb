# frozen_string_literal: true

class Analytics::PublicationExtract
  include ServicePattern

  def initialize(from:, to:)
    @start_date = from
    @end_date = to
  end

  def call
    countries.filter_map do |country|
      submissions = submitted_application_forms(country)

      next if submissions.empty?

      awards = awarded_application_forms(country)
      declines = declined_application_forms(country)
      withdraws = withdrawn_application_forms(country)

      induction_required =
        awards
          .joins(:assessment)
          .where(assessment: { induction_required: true })
          .count

      percent_induction_required =
        (
          if awards.empty?
            0
          else
            ((induction_required.to_f / awards.count) * 100).round
          end
        )

      {
        country_name: CountryName.from_country(country),
        applications: submissions.count,
        assessed: awards.count + declines.count,
        awarded: awards.count,
        declined: declines.count,
        withdrawn: withdraws.count,
        awaiting_decision:
          submissions.count - awards.count - declines.count - withdraws.count,
        induction_required:,
        percent_induction_required:,
      }
    end
  end

  private

  attr_reader :document, :start_date, :end_date

  delegate :documentable, to: :document

  def countries
    Country.all.sort_by { |country| CountryName.from_country(country) }
  end

  def submitted_application_forms(country)
    ApplicationForm
      .joins(region: :country)
      .where(region: { country: })
      .where("DATE(submitted_at) BETWEEN ? AND ?", start_date, end_date)
  end

  def awarded_application_forms(country)
    submitted_application_forms(country).where(
      "DATE(awarded_at) BETWEEN ? AND ?",
      start_date,
      end_date,
    )
  end

  def declined_application_forms(country)
    submitted_application_forms(country).where(
      "DATE(declined_at) BETWEEN ? AND ?",
      start_date,
      end_date,
    )
  end

  def withdrawn_application_forms(country)
    submitted_application_forms(country).where(
      "DATE(withdrawn_at) BETWEEN ? AND ?",
      start_date,
      end_date,
    )
  end
end
