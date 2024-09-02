# frozen_string_literal: true

require "rails_helper"

RSpec.describe RegistrationNumberValidators::Ghana, type: :model do
  subject(:validator) do
    described_class.new(
      registration_number:,
    )
  end

  let(:registration_number) { "PT/123456/1234" }

  describe "#valid?" do
    context "when all three parts of the license number are valid" do
      it "returns true" do
        expect(validator.valid?).to be(true)
      end
    end

    context "when the first part of the license number is invalid" do
      let(:registration_number) { "P/123456/1234" }

      it "returns false" do
        expect(validator.valid?).to be(false)
      end
    end

    context "when the second part of the license number is invalid" do
      let(:registration_number) { "PT/123&56/1234" }

      it "returns false" do
        expect(validator.valid?).to be(false)
      end
    end

    context "when the third part of the license number is invalid" do
      let(:registration_number) { "PT/123&56/1N34" }

      it "returns false" do
        expect(validator.valid?).to be(false)
      end
    end
  end

  describe "#license_number_part_one_valid?" do
    context "when the first part of the license number is valid" do
      it "returns true" do
        expect(validator.license_number_part_one_valid?).to be(true)
      end
    end

    context "when the first part of the license number has invalid number of characters" do
      let(:registration_number) { "PPT/123456/1234" }

      it "returns false" do
        expect(validator.license_number_part_one_valid?).to be(false)
      end
    end

    context "when the first part of the license number has incorrect format" do
      let(:registration_number) { "1$/123456/1234" }

      it "returns false" do
        expect(validator.license_number_part_one_valid?).to be(false)
      end
    end
  end

  describe "#license_number_part_two_valid?" do
    context "when the second part of the license number is valid" do
      it "returns true" do
        expect(validator.license_number_part_two_valid?).to be(true)
      end
    end

    context "when the second part of the license number has invalid number of characters" do
      let(:registration_number) { "PT/123456789/1234" }

      it "returns false" do
        expect(validator.license_number_part_two_valid?).to be(false)
      end
    end

    context "when the second part of the license number has incorrect format" do
      let(:registration_number) { "PT/12 B.5$/1234" }

      it "returns false" do
        expect(validator.license_number_part_two_valid?).to be(false)
      end
    end
  end

  describe "#license_number_part_three_valid?" do
    context "when the third part of the license number is valid" do
      it "returns true" do
        expect(validator.license_number_part_three_valid?).to be(true)
      end
    end

    context "when the third part of the license number has invalid number of characters" do
      let(:registration_number) { "PT/123456/122222" }

      it "returns false" do
        expect(validator.license_number_part_three_valid?).to be(false)
      end
    end

    context "when the third part of the license number has incorrect format" do
      let(:registration_number) { "PT/123456/123B" }

      it "returns false" do
        expect(validator.license_number_part_three_valid?).to be(false)
      end
    end
  end
end
