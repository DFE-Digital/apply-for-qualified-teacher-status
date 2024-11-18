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
        all_sections_necessary: true,
        requires_preliminary_check: false,
        sanction_check: "none",
        status_check: "none",
        teaching_authority_provides_written_statement: false,
        written_statement_optional: true,
      )
    end

    let(:valid) { form.valid? }
    let(:region) { create(:region) }
    let(:teaching_authority_requires_submission_email) { false }
    let(:teaching_authority_emails_string) { "" }
    let(:teaching_authority_name) { "Teaching Authority" }
    let(:teaching_authority_online_checker_url) { "" }

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
end
