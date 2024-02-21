# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::ReferenceRequestMisconductResponseForm,
               type: :model do
  let(:reference_request) { create(:reference_request) }

  subject(:form) do
    described_class.new(
      reference_request:,
      misconduct_response:,
      misconduct_comment:,
    )
  end

  describe "validations" do
    let(:misconduct_response) { "" }
    let(:misconduct_comment) { "" }

    it { is_expected.to validate_presence_of(:reference_request) }
    it { is_expected.to allow_values(true, false).for(:misconduct_response) }
    it { is_expected.to_not validate_presence_of(:misconduct_comment) }

    context "with a positive response" do
      let(:misconduct_response) { "true" }

      it { is_expected.to validate_presence_of(:misconduct_comment) }
    end
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    context "with a negative response" do
      let(:misconduct_response) { "false" }
      let(:misconduct_comment) { "" }

      it "sets misconduct_response" do
        expect { save }.to change(reference_request, :misconduct_response).to(
          false,
        )
      end

      it "ignores misconduct_comment" do
        expect { save }.to_not change(reference_request, :misconduct_comment)
      end
    end

    context "with a positive response" do
      let(:misconduct_response) { "true" }
      let(:misconduct_comment) { "Comment" }

      it "sets misconduct_response" do
        expect { save }.to change(reference_request, :misconduct_response).to(
          true,
        )
      end

      it "sets misconduct_comment" do
        expect { save }.to change(reference_request, :misconduct_comment).to(
          "Comment",
        )
      end
    end
  end
end
