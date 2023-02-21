# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::ReferenceRequestDatesResponseForm,
               type: :model do
  let(:reference_request) { create(:reference_request) }

  subject(:form) { described_class.new(reference_request:, dates_response:) }

  describe "validations" do
    let(:dates_response) { "" }

    it { is_expected.to validate_presence_of(:reference_request) }
    it { is_expected.to allow_values(true, false).for(:dates_response) }
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    let(:dates_response) { "true" }

    it "saves the reference request" do
      expect { save }.to change(reference_request, :dates_response).to(true)
    end
  end
end
