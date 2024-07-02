# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::ReferenceRequestDatesResponseForm,
               type: :model do
  subject(:form) do
    described_class.new(reference_request:, dates_response:, dates_comment:)
  end

  let(:reference_request) { create(:reference_request) }

  describe "validations" do
    let(:dates_response) { "" }
    let(:dates_comment) { "" }

    it { is_expected.to validate_presence_of(:reference_request) }
    it { is_expected.to allow_values(true, false).for(:dates_response) }
    it { is_expected.not_to validate_presence_of(:dates_comment) }

    context "with a negative response" do
      let(:dates_response) { "false" }

      it { is_expected.to validate_presence_of(:dates_comment) }
    end
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    context "with a positive response" do
      let(:dates_response) { "true" }
      let(:dates_comment) { "" }

      it "sets dates_response" do
        expect { save }.to change(reference_request, :dates_response).to(true)
      end

      it "ignores dates_comment" do
        expect { save }.not_to change(reference_request, :dates_comment)
      end
    end

    context "with a negative response" do
      let(:dates_response) { "false" }
      let(:dates_comment) { "Comment" }

      it "sets dates_response" do
        expect { save }.to change(reference_request, :dates_response).to(false)
      end

      it "sets dates_comment" do
        expect { save }.to change(reference_request, :dates_comment).to(
          "Comment",
        )
      end
    end
  end
end
