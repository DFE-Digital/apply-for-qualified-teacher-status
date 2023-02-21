# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::ReferenceRequestSatisfiedResponseForm,
               type: :model do
  let(:reference_request) { create(:reference_request) }

  subject(:form) do
    described_class.new(reference_request:, satisfied_response:)
  end

  describe "validations" do
    let(:satisfied_response) { "" }

    it { is_expected.to validate_presence_of(:reference_request) }
    it { is_expected.to allow_values(true, false).for(:satisfied_response) }
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    let(:satisfied_response) { "true" }

    it "saves the reference request" do
      expect { save }.to change(reference_request, :satisfied_response).to(true)
    end
  end
end
