# frozen_string_literal: true

class Analytics::PublicationExtract
  include ServicePattern

  def initialize(from:, to:)
    @start_date = from
    @end_date = to
  end

  def call
    countries.filter_map do |country|
      application_forms = application_forms_for_country(country)

      next if application_forms.empty?

      applications = application_forms.count
      awarded = application_forms.count(&:awarded?)
      declined = application_forms.count(&:declined?)
      withdrawn = application_forms.count(&:withdrawn?)

      induction_required =
        application_forms.count do |application_form|
          application_form.awarded? &&
            application_form.assessment.induction_required
        end

      {
        country_name: CountryName.from_country(country),
        applications:,
        assessed: awarded + declined,
        awarded:,
        declined:,
        withdrawn:,
        awaiting_decision: applications - awarded - declined - withdrawn,
        induction_required:,
        percent_induction_required: percent_of(induction_required, awarded),
      }
    end
  end

  private

  attr_reader :document, :start_date, :end_date

  delegate :documentable, to: :document

  def countries
    Country.all.sort_by { |country| CountryName.from_country(country) }
  end

  def application_forms_for_country(country)
    ApplicationForm
      .joins(region: :country)
      .includes(:assessment)
      .where(region: { country: })
      .where("DATE(submitted_at) BETWEEN ? AND ?", start_date, end_date)
  end

  def percent_of(numerator, denominator)
    return 0 if numerator.zero? || denominator.zero?

    ((numerator.to_f / denominator) * 100).round
  end
end
