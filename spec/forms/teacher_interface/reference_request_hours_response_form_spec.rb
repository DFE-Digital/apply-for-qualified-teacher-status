# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::ReferenceRequestHoursResponseForm,
               type: :model do
  subject(:form) do
    described_class.new(reference_request:, hours_response:, hours_comment:)
  end

  let(:reference_request) { create(:reference_request) }

  describe "validations" do
    let(:hours_response) { "" }
    let(:hours_comment) { "" }

    it { is_expected.to validate_presence_of(:reference_request) }
    it { is_expected.to allow_values(true, false).for(:hours_response) }
    it { is_expected.not_to validate_presence_of(:hours_comment) }

    context "with a negative response" do
      let(:hours_response) { "false" }

      it { is_expected.to validate_presence_of(:hours_comment) }
    end
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    context "with a positive response" do
      let(:hours_response) { "true" }
      let(:hours_comment) { "" }

      it "sets hours_response" do
        expect { save }.to change(reference_request, :hours_response).to(true)
      end

      it "ignores hours_comment" do
        expect { save }.not_to change(reference_request, :hours_comment)
      end
    end

    context "with a negative response" do
      let(:hours_response) { "false" }
      let(:hours_comment) { "Comment" }

      it "sets hours_response" do
        expect { save }.to change(reference_request, :hours_response).to(false)
      end

      it "sets hours_comment" do
        expect { save }.to change(reference_request, :hours_comment).to(
          "Comment",
        )
      end
    end
  end
end
