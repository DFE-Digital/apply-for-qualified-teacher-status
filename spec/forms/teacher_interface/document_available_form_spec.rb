require "rails_helper"

RSpec.describe TeacherInterface::DocumentAvailableForm, type: :model do
  let(:document) { create(:document) }

  subject(:form) { described_class.new(document:, available:) }

  describe "validations" do
    let(:available) { "" }

    it { is_expected.to validate_presence_of(:document) }
    it { is_expected.to allow_values(true, false).for(:available) }
  end

  describe "#save" do
    before { form.save(validate: true) }

    context "when available" do
      let(:available) { "true" }

      it "saves the document" do
        expect(document.available).to eq(true)
        expect(document.completed).to eq(false)
      end
    end

    context "when unavailable" do
      let(:available) { "false" }

      it "saves the document" do
        expect(document.available).to eq(false)
        expect(document.completed).to eq(true)
      end
    end
  end
end
