# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::ReferenceRequestReportsResponseForm,
               type: :model do
  subject(:form) do
    described_class.new(reference_request:, reports_response:, reports_comment:)
  end

  let(:reference_request) { create(:reference_request) }

  describe "validations" do
    let(:reports_response) { "" }
    let(:reports_comment) { "" }

    it { is_expected.to validate_presence_of(:reference_request) }
    it { is_expected.to allow_values(true, false).for(:reports_response) }
    it { is_expected.not_to validate_presence_of(:reports_comment) }

    context "with a negative response" do
      let(:reports_response) { "false" }

      it { is_expected.to validate_presence_of(:reports_comment) }
    end
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    context "with a positive response" do
      let(:reports_response) { "true" }
      let(:reports_comment) { "" }

      it "sets reports_response" do
        expect { save }.to change(reference_request, :reports_response).to(true)
      end

      it "ignores reports_comment" do
        expect { save }.not_to change(reference_request, :reports_comment)
      end
    end

    context "with a negative response" do
      let(:reports_response) { "false" }
      let(:reports_comment) { "Comment" }

      it "sets reports_response" do
        expect { save }.to change(reference_request, :reports_response).to(
          false,
        )
      end

      it "sets reports_comment" do
        expect { save }.to change(reference_request, :reports_comment).to(
          "Comment",
        )
      end
    end
  end
end
