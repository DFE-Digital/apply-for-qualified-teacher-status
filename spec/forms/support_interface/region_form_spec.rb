# frozen_string_literal: true

require "rails_helper"

RSpec.describe SupportInterface::RegionForm, type: :model do
  describe "#valid?" do
    subject(:valid) { form.valid? }
    
    let(:teaching_authority_requires_submission_email) { true }
    let(:teaching_authority_emails_string) {"test@test.com, test2@test.com"}
    let(:work_history_section_to_omit) { nil }
    let(:all_sections_necessary) { true }
    let(:region) { create(:region) }
    let(:save!) { form.save! }
    let(:form) do
      described_class.new(
        teaching_authority_emails_string:,
        region:,
        teaching_authority_requires_submission_email:,
        all_sections_necessary:,
        requires_preliminary_check: false,
        sanction_check: "none",
        status_check: "none",
        teaching_authority_provides_written_statement: false,
        written_statement_optional: true,
      )
    end

    context "when applicants need to complete all sections" do

      context "when yes is selected" do
        it do
          is_expected.to be_truthy
        end
      end
    end

    context "when applicants do not need to complete all sections" do

      context "when no is selected" do
        let(:all_sections_necessary) { false }
        let(:work_history_section_to_omit) { "whole_section" }

        it do 
          save!
          expect(form).to validate_inclusion_of(:work_history_section_to_omit).in_array(%w[whole_section contact_details])
        end
      end
    end

    context "when teaching authority requires submission email" do

      context "when teaching authority emails string is blank" do
        let(:teaching_authority_emails_string) { "" }

        it { is_expected.to be_falsey }

        it "adds an error to the teaching_authority_emails_string field" do
          subject
          expect(form.errors[:teaching_authority_emails_string]).to include(
            "You must provide an email for the teaching authority.",
          )
        end
      end

      context "when teaching authority emails string is not blank" do

        it { is_expected.to be_truthy }
      end
    end

    context "when teaching authority does not require submission email" do
      let(:teaching_authority_requires_submission_email) { false }

      context "when teaching authority emails string is blank" do
        let(:teaching_authority_emails_string) { "" }

        it { is_expected.to be_truthy }
      end

      context "when teaching authority emails string is not blank" do
        let(:teaching_authority_emails_string) do
          "test@test.com, test2@test.com"
        end

        it { is_expected.to be_truthy }
      end
    end
  end
end
