require "rails_helper"

RSpec.describe AssessorInterface::FurtherInformationRequestForm, type: :model do
  let(:further_information_request) { create(:further_information_request) }
  let(:user) { create(:staff, :confirmed) }
  let(:attributes) { {} }

  subject(:form) do
    described_class.new(further_information_request:, user:, **attributes)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:further_information_request) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to allow_values(true, false).for(:passed) }

    context "when passed" do
      let(:attributes) { { passed: true } }

      it { is_expected.to_not validate_presence_of(:failure_assessor_note) }
    end

    context "when not passed" do
      let(:attributes) { { passed: false } }

      it { is_expected.to validate_presence_of(:failure_assessor_note) }
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    context "with invalid attributes" do
      it { is_expected.to be false }
    end

    context "with valid attributes" do
      let(:attributes) { { passed: true, failure_assessor_note: "" } }

      it "updates the application form" do
        expect { save }.to change(further_information_request, :passed).from(
          nil,
        ).to(true)
      end

      it "creates a timeline event" do
        expect { save }.to change {
          TimelineEvent.further_information_request_assessed.count
        }.by(1)
      end
    end
  end
end
