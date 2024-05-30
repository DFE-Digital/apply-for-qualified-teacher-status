# frozen_string_literal: true

class ConfigurationSync::Exporter
  include ServicePattern

  def initialize(file:)
    @file = file
  end

  def call
    file.write(serialise.to_json)
  end

  private

  attr_reader :file

  def serialise
    {
      countries: Country.all.map { |country| serialise_country(country) },
      english_language_providers:
        EnglishLanguageProvider.all.map do |english_language_provider|
          serialise_english_language_provider(english_language_provider)
        end,
      regions:
        Region.includes(:country).map { |region| serialise_region(region) },
    }
  end

  def serialise_country(country)
    {
      code: country.code,
      eligibility_enabled: country.eligibility_enabled,
      eligibility_skip_questions: country.eligibility_skip_questions,
      other_information: country.other_information,
      sanction_information: country.sanction_information,
      status_information: country.status_information,
      subject_limited: country.subject_limited,
      teaching_qualification_information:
        country.teaching_qualification_information,
    }
  end

  def serialise_english_language_provider(english_language_provider)
    {
      accepted_tests: english_language_provider.accepted_tests,
      b2_level_requirement: english_language_provider.b2_level_requirement,
      b2_level_requirement_prefix:
        english_language_provider.b2_level_requirement_prefix,
      check_url: english_language_provider.check_url,
      name: english_language_provider.name,
      reference_hint: english_language_provider.reference_hint,
      reference_name: english_language_provider.reference_name,
      url: english_language_provider.url,
    }
  end

  def serialise_region(region)
    {
      application_form_skip_work_history:
        region.application_form_skip_work_history,
      country_code: region.country.code,
      name: region.name,
      other_information: region.other_information,
      reduced_evidence_accepted: region.reduced_evidence_accepted,
      sanction_check: region.sanction_check,
      sanction_information: region.sanction_information,
      status_check: region.status_check,
      status_information: region.status_information,
      teaching_authority_address: region.teaching_authority_address,
      teaching_authority_certificate: region.teaching_authority_certificate,
      teaching_authority_emails: region.teaching_authority_emails,
      teaching_authority_name: region.teaching_authority_name,
      teaching_authority_online_checker_url:
        region.teaching_authority_online_checker_url,
      teaching_authority_provides_written_statement:
        region.teaching_authority_provides_written_statement,
      teaching_authority_requires_submission_email:
        region.teaching_authority_requires_submission_email,
      teaching_authority_websites: region.teaching_authority_websites,
      teaching_qualification_information:
        region.teaching_qualification_information,
      written_statement_optional: region.written_statement_optional,
    }
  end
end
