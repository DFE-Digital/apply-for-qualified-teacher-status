# frozen_string_literal: true

require "rails_helper"

RSpec.describe SupportRequestForm, type: :model do
  subject(:form) do
    described_class.new(
      email:,
      name:,
      comment:,
      user_type:,
      application_enquiry_type:,
      application_reference:,
    )
  end

  describe "validations" do
    let(:email) { "" }
    let(:name) { "" }
    let(:comment) { "" }
    let(:user_type) { "" }
    let(:application_enquiry_type) { "" }
    let(:application_reference) { "" }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:comment) }
    it { is_expected.to validate_presence_of(:user_type) }

    it { is_expected.not_to validate_presence_of(:application_enquiry_type) }
    it { is_expected.not_to validate_presence_of(:application_reference) }

    context "when user_type is application_submitted" do
      let(:user_type) { "application_submitted" }

      it { is_expected.to validate_presence_of(:application_enquiry_type) }
      it { is_expected.to validate_presence_of(:application_reference) }
    end

    context "when comment is less than 30 characters long" do
      let(:email) { "test@example.com" }
      let(:name) { "John Smith" }
      let(:comment) { "I need some help!" }
      let(:user_type) { "application_submitted" }
      let(:application_enquiry_type) { "other" }
      let(:application_reference) { "000001" }

      it { is_expected.not_to be_valid }
    end

    context "when comment is between than 30 and 20,000 characters long" do
      let(:email) { "test@example.com" }
      let(:name) { "John Smith" }
      let(:comment) { "I need some help!" * 3 }
      let(:user_type) { "application_submitted" }
      let(:application_enquiry_type) { "other" }
      let(:application_reference) { "000001" }

      it { is_expected.to be_valid }
    end

    context "when comment is over 20,000 characters long" do
      let(:email) { "test@example.com" }
      let(:name) { "John Smith" }
      let(:comment) { "I need some help!" * 2000 }
      let(:user_type) { "application_submitted" }
      let(:application_enquiry_type) { "other" }
      let(:application_reference) { "000001" }

      it { is_expected.not_to be_valid }
    end
  end

  describe "#save" do
    let(:email) { "test@example.com" }
    let(:name) { "John Smith" }
    let(:comment) { "I need some help!" * 3 }
    let(:user_type) { "application_submitted" }
    let(:application_enquiry_type) { "other" }
    let(:application_reference) { "000001" }

    it "generates a new support request record" do
      expect { form.save }.to change(SupportRequest, :count).by(1)

      support_request = SupportRequest.last

      expect(support_request).to have_attributes(
        email:,
        name:,
        comment:,
        user_type:,
        application_enquiry_type:,
        application_reference:,
      )
    end

    it "enqueues a job to generate a request within Zendesk" do
      expect { form.save }.to have_enqueued_job(CreateZendeskRequestJob).with(
        SupportRequest.last,
      )
    end
  end
end
