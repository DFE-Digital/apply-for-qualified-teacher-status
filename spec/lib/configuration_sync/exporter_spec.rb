# frozen_string_literal: true

require "rails_helper"

RSpec.describe ConfigurationSync::Exporter do
  subject(:call) { described_class.call(file:) }

  let(:file) { StringIO.new }

  let(:parsed_file) do
    file.rewind
    JSON.parse(file.read)
  end

  before do
    country = create(:country, code: "FR")
    create(:region, country:, name: "Region")
    create(:english_language_provider, name: "Provider")
  end

  before { expect { call }.to_not raise_error }

  it "exports the countries" do
    expect(parsed_file).to include("countries")
    expect(parsed_file["countries"].first).to eq(
      {
        "code" => "FR",
        "eligibility_enabled" => true,
        "eligibility_skip_questions" => false,
        "other_information" => "",
        "qualifications_information" => "",
        "sanction_information" => "",
        "status_information" => "",
        "subject_limited" => false,
      },
    )
  end

  it "exports the english language providers" do
    expect(parsed_file).to include("english_language_providers")
    expect(parsed_file["english_language_providers"].first).to match(
      {
        "accepted_tests" => a_kind_of(String),
        "b2_level_requirement" => a_kind_of(String),
        "b2_level_requirement_prefix" => a_kind_of(String),
        "check_url" => a_kind_of(String),
        "name" => "Provider",
        "reference_hint" => a_kind_of(String),
        "reference_name" => a_kind_of(String),
        "url" => a_kind_of(String),
      },
    )
  end

  it "exports the regions" do
    expect(parsed_file).to include("regions")
    expect(parsed_file["regions"].first).to eq(
      {
        "application_form_skip_work_history" => false,
        "country_code" => "FR",
        "name" => "Region",
        "other_information" => "",
        "qualifications_information" => "",
        "reduced_evidence_accepted" => false,
        "sanction_check" => "none",
        "sanction_information" => "",
        "status_check" => "none",
        "status_information" => "",
        "teaching_authority_address" => "",
        "teaching_authority_certificate" => "",
        "teaching_authority_emails" => [],
        "teaching_authority_name" => "",
        "teaching_authority_online_checker_url" => "",
        "teaching_authority_provides_written_statement" => false,
        "teaching_authority_requires_submission_email" => false,
        "teaching_authority_websites" => [],
        "written_statement_optional" => false,
      },
    )
  end
end
