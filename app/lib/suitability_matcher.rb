# frozen_string_literal: true

class SuitabilityMatcher
  include ApplicationFormHelper
  include Gem::Text

  def flag_as_unsuitable?(application_form:)
    suitability_records.any? do |suitability_record|
      matches?(suitability_record:, application_form:)
    end
  end

  private

  attr_reader :application_form

  def suitability_records
    @suitability_records ||=
      SuitabilityRecord.active.includes(
        :emails,
        :names,
        application_forms: %i[country teacher],
      )
  end

  def fuzzy_match?(value_a, value_b)
    return false if value_a.blank? || value_b.blank?

    if value_a.is_a?(Date) && value_b.is_a?(Date)
      (value_a.day - value_b.day).abs <= 3 &&
        (value_a.month - value_b.month).abs <= 3 &&
        (value_a.year - value_b.year).abs <= 3
    elsif value_a.is_a?(String) && value_b.is_a?(String)
      levenshtein_distance(value_a, value_b) <= 3
    else
      false
    end
  end

  def matches?(application_form:, suitability_record:)
    if suitability_record.application_forms.any? { application_form == _1 }
      return true
    end

    canonical_email_a = application_form.teacher.canonical_email
    name_a = application_form_full_name(application_form)
    date_of_birth_a = application_form.date_of_birth
    country_code_a = application_form.country.code

    canonical_emails_b = suitability_record.emails.map(&:canonical)
    names_b = suitability_record.names.map(&:value)
    date_of_birth_b = suitability_record.date_of_birth
    country_code_b = suitability_record.country_code

    return true if canonical_emails_b.include?(canonical_email_a)

    if names_b.include?(name_a) && date_of_birth_a == date_of_birth_b
      return true
    end

    name_matches = names_b.any? { fuzzy_match?(name_a, _1) }

    number_of_matches = [
      name_matches,
      fuzzy_match?(date_of_birth_a, date_of_birth_b),
      canonical_emails_b.any? { fuzzy_match?(canonical_email_a, _1) },
    ].compact_blank.count

    number_of_matches == 3 ||
      (
        number_of_matches == 2 &&
          (name_matches || country_code_a == country_code_b)
      )
  end
end
