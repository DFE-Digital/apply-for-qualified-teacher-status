# frozen_string_literal: true

class SuitabilityMatcher
  include ApplicationFormHelper
  include Gem::Text
  include ServicePattern

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    matches_any_declined_due_to_suitability? || matches_any_suitability_records?
  end

  private

  attr_reader :application_form

  def full_name
    @full_name ||= application_form_full_name(application_form)
  end

  def canonical_email
    @canonical_email ||= application_form.teacher.canonical_email
  end

  def country_code
    @country_code ||= application_form.country.code
  end

  delegate :date_of_birth, to: :application_form

  def match?(value_a, value_b)
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

  def considered_a_match_with?(
    other_email_addresses,
    other_names,
    other_date_of_birth,
    other_country_code
  )
    return true if other_email_addresses.include?(canonical_email)

    if other_names.include?(full_name) && other_date_of_birth == date_of_birth
      return true
    end

    name_matches = other_names.any? { match?(full_name, _1) }

    number_of_matches = [
      name_matches,
      match?(date_of_birth, other_date_of_birth),
      other_email_addresses.any? { match?(canonical_email, _1) },
    ].compact_blank.count

    number_of_matches == 3 ||
      (
        number_of_matches == 2 &&
          (name_matches || country_code == other_country_code)
      )
  end

  def matches_other_application_form?(other_application_form)
    other_application_form == application_form ||
      considered_a_match_with?(
        [other_application_form.teacher.canonical_email],
        [application_form_full_name(other_application_form)],
        other_application_form.date_of_birth,
        other_application_form.country.code,
      )
  end

  SUITABILITY_FAILURE_REASONS = [
    FailureReasons::SUITABILITY,
    FailureReasons::SUITABILITY_PREVIOUSLY_DECLINED,
    FailureReasons::FRAUD,
  ].freeze

  def application_forms_declined_due_to_suitability
    SelectedFailureReason
      .includes(application_form: { region: :country })
      .where(key: SUITABILITY_FAILURE_REASONS)
      .map(&:application_form)
      .uniq
  end

  def matches_any_declined_due_to_suitability?
    application_forms_declined_due_to_suitability.any? do |other_application_form|
      matches_other_application_form?(other_application_form)
    end
  end

  def matches_any_suitability_records?
    SuitabilityRecord
      .includes(:emails, :names, application_forms: { region: :country })
      .any? do |suitability_record|
        matches_application_form =
          suitability_record.application_forms.any? do |application_form|
            matches_other_application_form?(application_form)
          end

        next true if matches_application_form

        considered_a_match_with?(
          suitability_record.emails.map(&:canonical),
          suitability_record.names.map(&:value),
          suitability_record.date_of_birth,
          suitability_record.country_code,
        )
      end
  end
end
