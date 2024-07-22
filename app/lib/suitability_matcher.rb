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

  def match?(string_a, string_b)
    levenshtein_distance(string_a, string_b) <= 3
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
      next true if other_application_form == application_form

      next false unless country_code == other_application_form.country.code

      unless match?(
               full_name,
               application_form_full_name(other_application_form),
             )
        next false
      end

      application_form.date_of_birth == other_application_form.date_of_birth ||
        match?(canonical_email, other_application_form.teacher.canonical_email)
    end
  end

  def matches_any_suitability_records?
    SuitabilityRecord
      .includes(:emails, :names, :application_forms)
      .any? do |suitability_record|
        if suitability_record.application_forms.include?(application_form)
          next true
        end

        next false unless country_code == suitability_record.country_code

        unless suitability_record.names.any? { match?(full_name, _1.value) }
          next false
        end

        application_form.date_of_birth == suitability_record.date_of_birth ||
          suitability_record.emails.any? do
            match?(canonical_email, _1.canonical)
          end
      end
  end
end
