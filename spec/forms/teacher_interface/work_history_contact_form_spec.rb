# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::WorkHistoryContactForm, type: :model do
  subject(:form) do
    described_class.new(
      work_history:,
      contact_name:,
      contact_job:,
      contact_email:,
    )
  end

  let(:work_history) { build(:work_history) }

  describe "validations" do
    let(:contact_name) { "" }
    let(:contact_job) { "" }
    let(:contact_email) { "" }

    it { is_expected.to validate_presence_of(:contact_name) }
    it { is_expected.to validate_presence_of(:contact_job) }
    it { is_expected.to validate_presence_of(:contact_email) }

    context "when contact email has public email domain" do
      let(:contact_name) { "John Doe" }
      let(:contact_job) { "Head Teacher" }
      let(:contact_email) { "test@gmail.com" }

      it { is_expected.to be_valid }
    end

    context "when the feature flag for requiring private email for referee is enabled" do
      before { FeatureFlags::FeatureFlag.activate(:email_domains_for_referees) }

      after do
        FeatureFlags::FeatureFlag.deactivate(:email_domains_for_referees)
      end

      context "when contact email has public email domain" do
        let(:contact_name) { "John Doe" }
        let(:contact_job) { "Head Teacher" }
        let(:contact_email) { "test@gmail.com" }

        it { is_expected.not_to be_valid }
      end
    end
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    let(:contact_name) { "First Last" }
    let(:contact_job) { "Job" }
    let(:contact_email) { "school@example.com" }

    context "when the feature flag for requiring private email for referee is not enabled" do
      before { expect(save).to be true }

      it "saves the work history" do
        expect(
          work_history.application_form.requires_private_email_for_referee,
        ).to be false
        expect(work_history.contact_name).to eq("First Last")
        expect(work_history.contact_job).to eq("Job")
        expect(work_history.contact_email).to eq("school@example.com")
        expect(work_history.contact_email_domain).to eq("example.com")
        expect(work_history.canonical_contact_email).to eq("school@example.com")
      end
    end

    context "when the feature flag for requiring private email for referee is enabled" do
      before do
        FeatureFlags::FeatureFlag.activate(:email_domains_for_referees)

        expect(save).to be true
      end

      after do
        FeatureFlags::FeatureFlag.deactivate(:email_domains_for_referees)
      end

      it "sets requires_private_email_for_referee to true on application form" do
        expect(
          work_history
            .application_form
            .reload
            .requires_private_email_for_referee,
        ).to be true
      end
    end

    context "with a complex email address" do
      let(:contact_email) { "first.last+123@gmail.com" }

      it "canonicalises the email address" do
        expect(save).to be true
        expect(work_history.canonical_contact_email).to eq(
          "firstlast@gmail.com",
        )
      end
    end
  end
end
