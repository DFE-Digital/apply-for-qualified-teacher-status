# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::SanctionConfirmationForm, type: :model do
  subject(:form) do
    described_class.new(application_form:, confirmed_no_sanctions:)
  end

  let(:application_form) { build(:application_form) }

  describe "validations" do
    context "when confirmed is false" do
      let(:confirmed_no_sanctions) { false }

      it { is_expected.not_to be_valid }
    end

    context "when confirmed is true" do
      let(:confirmed_no_sanctions) { true }

      it { is_expected.to be_valid }
    end

    context "when confirmed is nil" do
      let(:confirmed_no_sanctions) { nil }

      it { is_expected.not_to be_valid }
    end
  end

  describe "#save" do
    let(:confirmed_no_sanctions) { true }

    before { form.save(validate: true) }

    it "updates the application form" do
      expect(application_form).to be_confirmed_no_sanctions
    end
  end
end
