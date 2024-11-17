# frozen_string_literal: true

require "rails_helper"

RSpec.describe SupportInterface::RegionForm, type: :model do
  describe "#valid?" do
    let(:region) { create(:region) }
    let(:form) do
      described_class.new(
        region:,
        all_sections_necessary: true,
        #other_information: "Some information",
        requires_preliminary_check: true,
        sanction_check: "online",
        #sanction_information: "Some information",
        status_check: "written",
        #status_information: "Some information",
        #teaching_authority_address: "Some address",
        #teaching_authority_certificate: "Some certificate",
        teaching_authority_emails_string:
          "email1@example.com\nemail2@example.com",
        teaching_authority_name: "Teaching Authority",
        teaching_authority_online_checker_url: "https://example.com",
        teaching_authority_provides_written_statement: true,
        #teaching_authority_requires_submission_email: true,
        #teaching_authority_websites_string: "https://website1.com\nhttps://website2.com",
        #teaching_qualification_information: "Some information",
        #work_history_section_to_omit: "contact_details",
        written_statement_optional: false,
      )
    end

    it do
      expect(form).to be_valid
      expect(form.errors).to be_empty
    end

    it do
      expect(form).to allow_value(true).for(:all_sections_necessary)
      expect(form).to allow_value(false).for(:all_sections_necessary)
    end

    it do
      expect(form).to allow_value(true).for(:requires_preliminary_check)
      expect(form).to allow_value(false).for(:requires_preliminary_check)
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

    it do
      expect(subject).to allow_value("Teaching Authority").for(
        :teaching_authority_name,
      )
      expect(subject).not_to allow_value("The Teaching Authority").for(
        :teaching_authority_name,
      )
    end

    it do
      expect(subject).to allow_value(nil).for(
        :teaching_authority_online_checker_url,
      )
      expect(subject).to allow_value("https://example.com").for(
        :teaching_authority_online_checker_url,
      )
      expect(subject).not_to allow_value("invalid-url").for(
        :teaching_authority_online_checker_url,
      )
    end

    it do
      expect(form).to allow_value(true).for(
        :teaching_authority_provides_written_statement,
      )
      expect(form).to allow_value(false).for(
        :teaching_authority_provides_written_statement,
      )
    end

    it do
      expect(form).not_to validate_inclusion_of(
        :work_history_section_to_omit,
      ).in_array(%w[whole_section contact_details])
    end

    context "when all_sections_necessary is false" do
      before { form.all_sections_necessary = false }

      it do
        expect(form).to validate_inclusion_of(
          :work_history_section_to_omit,
        ).in_array(%w[whole_section contact_details])
      end
    end

    it do
      expect(form).to allow_value(true).for(:written_statement_optional)
      expect(form).to allow_value(false).for(:written_statement_optional)
    end
  end
end
