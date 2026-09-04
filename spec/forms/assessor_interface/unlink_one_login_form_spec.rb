# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::UnlinkOneLoginForm, type: :model do
  subject(:form) { described_class.new(teacher:, user:, confirm:) }

  let(:teacher) { create(:teacher, gov_one_id: "gov-one-id-123") }
  let(:user) { create(:staff) }
  let(:confirm) { true }

  describe "validations" do
    it { is_expected.to validate_presence_of(:teacher) }
    it { is_expected.to validate_presence_of(:user) }

    it "is valid when confirm is false" do
      form.confirm = false

      expect(form).to be_valid
    end

    it "is valid when confirm is true" do
      form.confirm = true

      expect(form).to be_valid
    end

    it "requires confirm to be a boolean" do
      form.confirm = nil

      expect(form).to be_invalid
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    context "when confirm is true" do
      let(:confirm) { true }

      it { is_expected.to be true }

      it "clears the teacher's gov_one_id" do
        expect { save }.to change(teacher, :gov_one_id).from(
          "gov-one-id-123",
        ).to(nil)
      end
    end

    context "when confirm is false" do
      let(:confirm) { false }

      it { is_expected.to be true }

      it "does not update the gov_one_id" do
        expect { save }.not_to(change(teacher, :gov_one_id))
      end
    end

    context "when the form is invalid" do
      let(:confirm) { nil }

      it { is_expected.to be false }

      it "does not update the teacher" do
        expect { save }.not_to(change(teacher, :gov_one_id))
      end
    end
  end
end
