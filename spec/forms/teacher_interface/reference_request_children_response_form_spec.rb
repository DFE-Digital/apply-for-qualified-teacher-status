# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::ReferenceRequestChildrenResponseForm,
               type: :model do
  subject(:form) do
    described_class.new(
      reference_request:,
      children_response:,
      children_comment:,
    )
  end

  let(:reference_request) { create(:reference_request) }

  describe "validations" do
    let(:children_response) { "" }
    let(:children_comment) { "" }

    it { is_expected.to validate_presence_of(:reference_request) }
    it { is_expected.to allow_values(true, false).for(:children_response) }
    it { is_expected.not_to validate_presence_of(:children_comment) }

    context "with a negative response" do
      let(:children_response) { "false" }

      it { is_expected.to validate_presence_of(:children_comment) }
    end
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    context "with a positive response" do
      let(:children_response) { "true" }
      let(:children_comment) { "" }

      it "sets children_response" do
        expect { save }.to change(reference_request, :children_response).to(
          true,
        )
      end

      it "ignores children_comment" do
        expect { save }.not_to change(reference_request, :children_comment)
      end
    end

    context "with a negative response" do
      let(:children_response) { "false" }
      let(:children_comment) { "Comment" }

      it "sets children_response" do
        expect { save }.to change(reference_request, :children_response).to(
          false,
        )
      end

      it "sets children_comment" do
        expect { save }.to change(reference_request, :children_comment).to(
          "Comment",
        )
      end
    end
  end
end
