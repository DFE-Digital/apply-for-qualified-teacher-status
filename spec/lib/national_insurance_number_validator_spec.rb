# frozen_string_literal: true

require "rails_helper"

RSpec.describe NationalInsuranceNumberValidator, type: :model do
  subject(:validator) do
    described_class.new(
      national_insurance_number_part_one:,
      national_insurance_number_part_two:,
      national_insurance_number_part_three:,
    )
  end

  let(:national_insurance_number_part_one) { "QQ" }
  let(:national_insurance_number_part_two) { "123456" }
  let(:national_insurance_number_part_three) { "A" }

  describe "#valid?" do
    context "when all three parts of the national insurance number are valid" do
      it "returns true" do
        expect(validator.valid?).to be(true)
      end
    end

    context "when the first part of the national insurance number is invalid" do
      let(:national_insurance_number_part_one) { "11" }

      it "returns false" do
        expect(validator.valid?).to be(false)
      end
    end

    context "when the second part of the national insurance number is invalid" do
      let(:national_insurance_number_part_two) { "ABCD" }

      it "returns false" do
        expect(validator.valid?).to be(false)
      end
    end

    context "when the third part of the national insurance number is invalid" do
      let(:national_insurance_number_part_three) { "BB" }

      it "returns false" do
        expect(validator.valid?).to be(false)
      end
    end
  end

  describe "#national_insurance_number_part_one_valid?" do
    context "when the first part of the national insurance number is valid" do
      it "returns true" do
        expect(validator.national_insurance_number_part_one_valid?).to be(true)
      end
    end

    context "when the first part of the national insurance number has invalid number of characters" do
      let(:national_insurance_number_part_one) { "QQB" }

      it "returns false" do
        expect(validator.national_insurance_number_part_one_valid?).to be(false)
      end
    end

    context "when the first part of the national insurance number has incorrect format" do
      let(:national_insurance_number_part_one) { "Q1" }

      it "returns false" do
        expect(validator.national_insurance_number_part_one_valid?).to be(false)
      end
    end
  end

  describe "#national_insurance_number_part_two_valid?" do
    context "when the second part of the national insurance number is valid" do
      it "returns true" do
        expect(validator.national_insurance_number_part_two_valid?).to be(true)
      end
    end

    context "when the second part of the national insurance number has invalid number of characters" do
      let(:national_insurance_number_part_two) { "12345" }

      it "returns false" do
        expect(validator.national_insurance_number_part_two_valid?).to be(false)
      end
    end

    context "when the second part of the national insurance number has incorrect format" do
      let(:national_insurance_number_part_two) { "1 A4.6" }

      it "returns false" do
        expect(validator.national_insurance_number_part_two_valid?).to be(false)
      end
    end
  end

  describe "#national_insurance_number_part_three_valid?" do
    context "when the third part of the national insurance number is valid" do
      it "returns true" do
        expect(validator.national_insurance_number_part_three_valid?).to be(
          true,
        )
      end
    end

    context "when the third part of the national insurance number has invalid number of characters" do
      let(:national_insurance_number_part_three) { "AA" }

      it "returns false" do
        expect(validator.national_insurance_number_part_three_valid?).to be(
          false,
        )
      end
    end

    context "when the third part of the national insurance number has incorrect format" do
      let(:national_insurance_number_part_three) { "1" }

      it "returns false" do
        expect(validator.national_insurance_number_part_three_valid?).to be(
          false,
        )
      end
    end
  end
end
