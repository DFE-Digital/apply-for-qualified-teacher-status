# frozen_string_literal: true

require "rails_helper"

RSpec.describe SupportInterface::RegionForm, type: :model do
  describe "#valid?" do
    subject(:form) do
      described_class.new(
        region:,
        teaching_authority_online_checker_url:,
        teaching_authority_name:,
        teaching_authority_emails_string:,
        teaching_authority_requires_submission_email:,
        all_sections_necessary:,
        requires_preliminary_check: false,
        sanction_check: "none",
        status_check: "none",
        teaching_authority_provides_written_statement: false,
        written_statement_optional: true,
        teaching_authority_websites_string: "",
        teaching_authority_address: "",
        other_information: "",
        teaching_authority_certificate: "",
        status_information: "",
        sanction_information: "",
        teaching_qualification_information: "",
      )
    end

    let(:save!) { form.save! }
    let(:valid) { form.valid? }
    let(:region) { create(:region) }
    let(:teaching_authority_requires_submission_email) { false }
    let(:teaching_authority_emails_string) { "" }
    let(:teaching_authority_name) { "Teaching Authority" }
    let(:teaching_authority_online_checker_url) { "" }
    let(:all_sections_necessary) { true }

    it do
      expect(subject).to validate_presence_of(
        :written_statement_optional,
      ).with_message(
        "Please choose whether applicant can submit without uploading the written statement",
      )
    end

    it do
      expect(subject).to validate_presence_of(
        :teaching_authority_provides_written_statement,
      ).with_message(
        "Please select whether teaching authority only send the letter of professional " \
          "standing (LOPS) directly to the DfE",
      )
    end

    it do
      expect(subject).to validate_presence_of(
        :all_sections_necessary,
      ).with_message(
        "Please select whether applicants need to complete all sections of the application form",
      )
    end

    it do
      expect(subject).to validate_presence_of(
        :requires_preliminary_check,
      ).with_message(
        "Please select whether this region requires a preliminary check",
      )
    end

    it do
      expect(subject).to validate_inclusion_of(:sanction_check).in_array(
        %w[online written none],
      )
    end

    it do
      expect(subject).to validate_inclusion_of(:status_check).in_array(
        %w[online written none],
      )
    end

    context "all_sections_necessary is false" do
      let(:all_sections_necessary) { false }

      it do
        valid
        expect(subject).to validate_inclusion_of(
          :work_history_section_to_omit,
        ).in_array(%w[whole_section contact_details])
      end
    end

    context "when teaching authority requires submission email" do
      let(:teaching_authority_requires_submission_email) { true }

      context "when teaching authority emails string is blank" do
        let(:teaching_authority_emails_string) { "" }

        it { is_expected.not_to be_valid }

        it "adds an error to the teaching_authority_emails_string field" do
          valid
          expect(form.errors[:teaching_authority_emails_string]).to include(
            "You must provide an email for the teaching authority.",
          )
        end
      end

      context "when teaching authority emails string is not blank" do
        let(:teaching_authority_emails_string) do
          "test@test.com, test2@test.com"
        end

        it { is_expected.to be_valid }
      end
    end

    context "when teaching authority does not require submission email" do
      let(:teaching_authority_requires_submission_email) { false }

      context "when teaching authority emails string is blank" do
        let(:teaching_authority_emails_string) { "" }

        it { is_expected.to be_valid }
      end

      context "when teaching authority emails string is not blank" do
        let(:teaching_authority_emails_string) do
          "test@test.com, test2@test.com"
        end

        it { is_expected.to be_valid }
      end
    end

    context "when teaching authority name includes 'the'" do
      let(:teaching_authority_name) { "The Teaching Authority" }

      it { is_expected.not_to be_valid }
    end

    context "when teaching authority online checker url is not a valid url" do
      let(:teaching_authority_online_checker_url) { "not a url" }

      it { is_expected.not_to be_valid }
    end

    context "when teaching authority online checker url is a valid url" do
      let(:teaching_authority_online_checker_url) { "https://www.example.com" }

      it { is_expected.to be_valid }
    end
  end

  describe "#save" do
    subject(:save!) { form.save! }

    let(:form) do
      described_class.new(
        region:,
        teaching_authority_online_checker_url: "",
        teaching_authority_name:,
        teaching_authority_emails_string:,
        teaching_authority_requires_submission_email: false,
        all_sections_necessary:,
        requires_preliminary_check: false,
        sanction_check: "none",
        status_check: "none",
        teaching_authority_provides_written_statement: false,
        written_statement_optional: true,
        teaching_authority_websites_string:,
        teaching_authority_address: "",
        other_information: "",
        teaching_authority_certificate: "",
        status_information: "",
        sanction_information: "",
        teaching_qualification_information: "",
        work_history_section_to_omit:,
      )
    end

    let(:region) { create(:region) }
    let(:teaching_authority_name) { "Teaching Authority" }
    let(:teaching_authority_emails_string) do
      "email1@example.com\nemail2@example.com"
    end
    let(:teaching_authority_websites_string) do
      "http://site1.com\nhttp://site2.com"
    end
    let(:work_history_section_to_omit) { "" }
    let(:all_sections_necessary) { true }

    context "when form is valid" do
      it "updates region attributes" do
        subject
        expect(region).to have_attributes(
          application_form_skip_work_history: false,
          other_information: "",
          reduced_evidence_accepted: false,
          requires_preliminary_check: false,
          sanction_check: "none",
          sanction_information: "",
          status_check: "none",
          status_information: "",
          teaching_authority_address: "",
          teaching_authority_certificate: "",
          teaching_authority_emails: %w[email1@example.com email2@example.com],
          teaching_authority_name: "Teaching Authority",
          teaching_authority_online_checker_url: "",
          teaching_authority_provides_written_statement: false,
          teaching_authority_requires_submission_email: false,
          teaching_authority_websites: %w[http://site1.com http://site2.com],
          teaching_qualification_information: "",
          written_statement_optional: true,
        )
      end
    end

    context "when work history section to omit is whole section" do
      let(:all_sections_necessary) { false }
      let(:work_history_section_to_omit) { "whole_section" }

      it do
        subject
        expect(region).to have_attributes(
          application_form_skip_work_history: true,
          reduced_evidence_accepted: false,
        )
      end
    end

    context "when work history section to omit is contact details" do
      let(:all_sections_necessary) { false }
      let(:work_history_section_to_omit) { "contact_details" }

      it do
        subject
        expect(region).to have_attributes(
          reduced_evidence_accepted: true,
          application_form_skip_work_history: false,
        )
      end
    end

    context "when form is invalid" do
      let(:teaching_authority_name) { "The Teaching Authority" }

      it "returns false" do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "does not change region attributes when form is invalid" do
        original_attributes = region.attributes
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
        expect(region.reload.attributes).to eq(original_attributes)
      end
    end
  end

  describe ".for_existing_region" do
    subject(:form) { described_class.for_existing_region(region) }

    let(:region) do
      create(
        :region,
        application_form_skip_work_history:,
        other_information:,
        reduced_evidence_accepted:,
        requires_preliminary_check:,
        sanction_check:,
        sanction_information:,
        status_check:,
        status_information:,
        teaching_authority_address:,
        teaching_authority_certificate:,
        teaching_authority_emails:,
        written_statement_optional:,
      )
    end

    let(:application_form_skip_work_history) { false }
    let(:other_information) { "Other information" }
    let(:reduced_evidence_accepted) { false }
    let(:requires_preliminary_check) { false }
    let(:sanction_check) { "none" }
    let(:sanction_information) { "Sanction information" }
    let(:status_check) { "none" }
    let(:status_information) { "Status information" }
    let(:teaching_authority_address) { "Teaching Authority Address" }
    let(:teaching_authority_certificate) { "Teaching Authority Certificate" }
    let(:teaching_authority_emails) { %w[http://site1.com http://site2.com] }
    let(:written_statement_optional) { true }

    it "returns a RegionForm for the region" do
      expect(subject).to have_attributes(
        all_sections_necessary: true,
        other_information: "Other information",
        requires_preliminary_check: false,
        sanction_check: "none",
        sanction_information: "Sanction information",
        status_check: "none",
        status_information: "Status information",
        teaching_authority_address: "Teaching Authority Address",
        teaching_authority_certificate: "Teaching Authority Certificate",
        teaching_authority_emails_string: "http://site1.com\nhttp://site2.com",
        teaching_authority_name: "",
        teaching_authority_online_checker_url: "",
        teaching_authority_provides_written_statement: false,
        teaching_authority_requires_submission_email: false,
        teaching_authority_websites_string: "",
        teaching_qualification_information: "",
        work_history_section_to_omit: nil,
        written_statement_optional: true,
      )
    end

    context "when application_form_skip_work_history is true" do
      let(:application_form_skip_work_history) { true }

      it "sets all_sections_necessary to false" do
        expect(subject.all_sections_necessary).to be(false)
      end

      it "sets work_history_section_to_omit to whole_section" do
        expect(subject.work_history_section_to_omit).to eq("whole_section")
      end
    end

    context "when reduced_evidence_accepted is true" do
      let(:reduced_evidence_accepted) { true }

      it "sets all_sections_necessary to false" do
        expect(subject.all_sections_necessary).to be(false)
      end

      it "sets work_history_section_to_omit to contact_details" do
        expect(subject.work_history_section_to_omit).to eq("contact_details")
      end
    end
  end
end
