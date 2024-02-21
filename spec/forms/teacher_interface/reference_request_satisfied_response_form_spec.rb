# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::ReferenceRequestSatisfiedResponseForm,
               type: :model do
  let(:reference_request) { create(:reference_request) }

  subject(:form) do
    described_class.new(
      reference_request:,
      satisfied_response:,
      satisfied_comment:,
    )
  end

  describe "validations" do
    let(:satisfied_response) { "" }
    let(:satisfied_comment) { "" }

    it { is_expected.to validate_presence_of(:reference_request) }
    it { is_expected.to allow_values(true, false).for(:satisfied_response) }
    it { is_expected.to_not validate_presence_of(:satisfied_comment) }

    context "with a negative response" do
      let(:satisfied_response) { "false" }

      it { is_expected.to validate_presence_of(:satisfied_comment) }
    end
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    context "with a positive response" do
      let(:satisfied_response) { "true" }
      let(:satisfied_comment) { "" }

      it "sets satisfied_response" do
        expect { save }.to change(reference_request, :satisfied_response).to(
          true,
        )
      end

      it "ignores satisfied_comment" do
        expect { save }.to_not change(reference_request, :satisfied_comment)
      end
    end

    context "with a negative response" do
      let(:satisfied_response) { "false" }
      let(:satisfied_comment) { "Comment" }

      it "sets satisfied_response" do
        expect { save }.to change(reference_request, :satisfied_response).to(
          false,
        )
      end

      it "sets satisfied_comment" do
        expect { save }.to change(reference_request, :satisfied_comment).to(
          "Comment",
        )
      end
    end
  end
end
