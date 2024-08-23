# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::GhanaRegistrationNumberForm, type: :model do
  subject(:form) do
    described_class.new(application_form:, license_number_parts:)
  end

  let(:application_form) { build(:application_form) }

  describe "validations" do
    let(:license_number_parts) { [] }

    it { is_expected.to validate_presence_of(:application_form) }

    context "with empty parts" do
      it { is_expected.to be_invalid }
    end

    context "with invalid parts" do
      let(:license_number_parts) { %w[a b c] }

      it { is_expected.to be_invalid }
    end

    context "with valid parts" do
      let(:license_number_parts) { %w[PT 123456 1234] }

      it { is_expected.to be_valid }
    end
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    context "with valid parts" do
      let(:license_number_parts) { %w[PT 123456 1234] }

      it "sets the registration number to the string" do
        expect { save }.to change(application_form, :registration_number).to(
          "PT/123456/1234",
        )
      end
    end
  end
end
