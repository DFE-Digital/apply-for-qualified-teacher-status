module FurtherInformationRequestExpirable
  FOUR_WEEK_COUNTRY_CODES = %w[AU CA GI NZ US].freeze

  delegate :assessment, to: :further_information_request
  delegate :application_form, to: :assessment
  delegate :region, to: :application_form
  delegate :country, to: :region

  def days_until_expiry
    today = Time.zone.now.to_date
    date_due = (further_information_request.created_at + time_allowed).to_date

    (date_due - today).to_i
  end

  def time_allowed
    return 4.weeks if FOUR_WEEK_COUNTRY_CODES.include?(country.code)

    6.weeks
  end
end
