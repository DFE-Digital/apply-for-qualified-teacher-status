# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::CreateApplicationHoldForm, type: :model do
  subject do
    described_class.new(application_form:, user:, reason:, reason_comment:)
  end

  let(:application_form) { create(:application_form) }
  let(:user) { create(:staff) }
  let(:reason) { "suitability_check" }
  let(:reason_comment) { "" }

  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:reason) }

    it { is_expected.not_to validate_presence_of(:reason_comment) }

    context "when reason is other" do
      let(:reason) { "other" }

      it { is_expected.to validate_presence_of(:reason_comment) }
    end

    context "when application form is already on hold" do
      before { create :application_hold, application_form: }

      it { is_expected.not_to be_valid }
    end
  end

  describe "#save" do
    it "creates a hold for application form" do
      expect { subject.save }.to change(ApplicationHold, :count).by(1)

      expect(application_form.reload.active_application_hold).not_to be_nil
      expect(application_form.active_application_hold.reason).to eq(reason)
    end
  end
end
