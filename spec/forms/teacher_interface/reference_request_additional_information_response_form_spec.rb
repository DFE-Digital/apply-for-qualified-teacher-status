# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::ReferenceRequestAdditionalInformationResponseForm,
               type: :model do
  subject(:form) do
    described_class.new(reference_request:, additional_information_response:)
  end

  let(:reference_request) { create(:reference_request) }

  describe "validations" do
    let(:additional_information_response) { "" }

    it { is_expected.to validate_presence_of(:reference_request) }

    it do
      expect(subject).not_to validate_presence_of(
        :additional_information_response,
      )
    end
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    let(:additional_information_response) { "Some information." }

    it "saves the application form" do
      expect { save }.to change(
        reference_request,
        :additional_information_response,
      ).to("Some information.")
    end
  end
end
