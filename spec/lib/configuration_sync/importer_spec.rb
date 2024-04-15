# frozen_string_literal: true

require "rails_helper"

RSpec.describe ConfigurationSync::Importer do
  subject(:call) { described_class.call(file:) }

  let(:file) { StringIO.new(exporter_json) }

  let(:exporter_json) { <<-JSON }
      {
        "countries": [
          {
            "code": "FR",
            "eligibility_enabled": true,
            "eligibility_skip_questions": false,
            "other_information": "",
            "qualifications_information": "",
            "sanction_information": "",
            "status_information": "",
            "subject_limited": false
          }
        ],
        "english_language_providers": [
          {
            "accepted_tests": "Impedit possimus velit aliquid.",
            "b2_level_requirement": "aut",
            "b2_level_requirement_prefix": "Odit quod dolorem aspernatur.",
            "check_url": "http://barton.test/eva",
            "name": "Provider",
            "reference_hint": "Laudantium esse qui ea.",
            "reference_name": "illum",
            "url": "http://krajcik.example/arron.ebert"
          }
        ],
        "regions": [
          {
            "application_form_skip_work_history": false,
            "country_code": "FR",
            "name": "Region",
            "other_information": "",
            "qualifications_information": "",
            "reduced_evidence_accepted": false,
            "sanction_check": "none",
            "sanction_information": "",
            "status_check": "none",
            "status_information": "",
            "teaching_authority_address": "",
            "teaching_authority_certificate": "",
            "teaching_authority_emails": [],
            "teaching_authority_name": "",
            "teaching_authority_online_checker_url": "",
            "teaching_authority_provides_written_statement": false,
            "teaching_authority_requires_submission_email": false,
            "teaching_authority_websites": [],
            "written_statement_optional": false
          }
        ]
      }
    JSON

  it "imports the countries" do
    expect { call }.to change(Country, :count).by(1)
  end

  it "imports the english language providers" do
    expect { call }.to change(EnglishLanguageProvider, :count).by(1)
  end

  it "imports the regions" do
    expect { call }.to change(Region, :count).by(1)
  end
end
