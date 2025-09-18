# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::FurtherInformationRequestItemWorkHistoryContactForm,
               type: :model do
  subject(:form) do
    described_class.new(
      further_information_request_item:,
      contact_name:,
      contact_job:,
      contact_email:,
    )
  end

  let(:further_information_request_item) do
    create(
      :further_information_request_item,
      :with_work_history_contact_response,
    )
  end

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

    context "when the application form requires private email for referee is enabled" do
      before do
        further_information_request_item.application_form.update!(
          requires_private_email_for_referee: true,
        )
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

    before { expect(save).to be true }

    it "saves the work history contact information" do
      expect(further_information_request_item.contact_name).to eq("First Last")
      expect(further_information_request_item.contact_job).to eq("Job")
      expect(further_information_request_item.contact_email).to eq(
        "school@example.com",
      )
    end
  end
end
