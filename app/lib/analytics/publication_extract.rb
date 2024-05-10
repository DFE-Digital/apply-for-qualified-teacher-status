# frozen_string_literal: true

class Analytics::PublicationExtract
  include ServicePattern

  def initialize(from:, to:)
    @start_date = from
    @end_date = to
  end

  def call
    countries.map do |country|
      submissions = submitted_application_forms(country)
      awards = awarded_application_forms(country)
      declines = declined_application_forms(country)
      withdraws = withdrawn_application_forms(country)

      awarded = awards.count

      induction_required =
        awards
          .select { |application_form| requires_induction?(application_form) }
          .count

      {
        country_name: CountryName.from_country(country),
        applications: submissions.count,
        assessed: awarded + declines.count,
        awarded:,
        declined: declines.count,
        withdrawn: withdraws.count,
        awaiting_decision:
          submissions.count - awarded + declines.count - withdraws.count,
        awardees_with_only_ebacc_subject_or_subjects:
          awards.count do |application_form|
            has_only_ebacc_subjects?(application_form)
          end,
        awardees_with_no_ebacc_subjects:
          awards.count do |application_form|
            has_no_ebacc_subjects?(application_form)
          end,
        awardees_with_a_mix_of_subjects_at_least_one_is_ebacc:
          awards.count do |application_form|
            !has_only_ebacc_subjects?(application_form) &&
              !has_no_ebacc_subjects?(application_form)
          end,
        induction_required:,
        percent_induction_required:
          awarded.zero? ? 0 : ((induction_required / awarded) * 100).round(1),
      }
    end
  end

  private

  attr_reader :document

  delegate :documentable, to: :document

  def countries
    Country.all.sort_by { |country| CountryName.from_country(country) }
  end

  def submitted_application_forms(country)
    ApplicationForm.joins(region: :country).where(
      submitted_at: date_range,
      region: {
        country:,
      },
    )
  end

  def awarded_application_forms(country)
    ApplicationForm.joins(region: :country).where(
      awarded_at: date_range,
      region: {
        country:,
      },
    )
  end

  def declined_application_forms(country)
    ApplicationForm.joins(region: :country).where(
      declined_at: date_range,
      region: {
        country:,
      },
    )
  end

  def withdrawn_application_forms(country)
    ApplicationForm.joins(region: :country).where(
      withdrawn_at: date_range,
      region: {
        country:,
      },
    )
  end

  def has_only_ebacc_subjects?(application_form)
    Subject.find(application_form.assessment.subjects).all?(&:ebacc?)
  end

  def has_no_ebacc_subjects?(application_form)
    Subject.find(application_form.assessment.subjects).none?(&:ebacc?)
  end

  def requires_induction?(application_form)
    application_form.assessment.induction_required
  end

  def date_range
    @start_date..@end_date
  end
end
