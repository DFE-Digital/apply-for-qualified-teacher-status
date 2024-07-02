# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::ReferenceRequestLessonsResponseForm,
               type: :model do
  subject(:form) do
    described_class.new(reference_request:, lessons_response:, lessons_comment:)
  end

  let(:reference_request) { create(:reference_request) }

  describe "validations" do
    let(:lessons_response) { "" }
    let(:lessons_comment) { "" }

    it { is_expected.to validate_presence_of(:reference_request) }
    it { is_expected.to allow_values(true, false).for(:lessons_response) }
    it { is_expected.not_to validate_presence_of(:lessons_comment) }

    context "with a negative response" do
      let(:lessons_response) { "false" }

      it { is_expected.to validate_presence_of(:lessons_comment) }
    end
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    context "with a positive response" do
      let(:lessons_response) { "true" }
      let(:lessons_comment) { "" }

      it "sets lessons_response" do
        expect { save }.to change(reference_request, :lessons_response).to(true)
      end

      it "ignores lessons_comment" do
        expect { save }.not_to change(reference_request, :lessons_comment)
      end
    end

    context "with a negative response" do
      let(:lessons_response) { "false" }
      let(:lessons_comment) { "Comment" }

      it "sets lessons_response" do
        expect { save }.to change(reference_request, :lessons_response).to(
          false,
        )
      end

      it "sets lessons_comment" do
        expect { save }.to change(reference_request, :lessons_comment).to(
          "Comment",
        )
      end
    end
  end
end
