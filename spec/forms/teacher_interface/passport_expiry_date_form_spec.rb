# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::PassportExpiryDateForm, type: :model do
  subject(:form) do
    described_class.new(application_form:, passport_expiry_date:)
  end

  let(:application_form) { build(:application_form) }

  describe "validations" do
    let(:passport_expiry_date) { "" }

    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:passport_expiry_date) }

    context "when the expiry date is in the future" do
      let(:passport_expiry_date) do
        { 1 => 2.years.from_now.year, 2 => 1, 3 => 1 }
      end

      it { is_expected.to be_valid }
    end

    context "with an invalid expiry date" do
      subject(:error_message) { form.errors[:passport_expiry_date] }

      before { form.valid? }

      context "when expiry date has a 2 digit year" do
        let(:passport_expiry_date) { { 1 => 80, 2 => 1, 3 => 1 } }

        it do
          expect(subject).to eq(
            [
              "The passport expiry date must be entered as numbers, " \
                "including the day, month and year. For example, 27 3 2007.",
            ],
          )
        end
      end

      context "when expiry date is an invalid date" do
        let(:passport_expiry_date) { { 1 => 1990, 2 => 13, 3 => 40 } }

        it do
          expect(subject).to eq(
            [
              "The passport expiry date must be entered as numbers, " \
                "including the day, month and year. For example, 27 3 2007.",
            ],
          )
        end
      end
    end
  end

  describe "#save" do
    let(:passport_expiry_date) do
      { 1 => 2.years.from_now.year, 2 => 1, 3 => 1 }
    end

    before { form.save(validate: true) }

    it "saves the application form" do
      expect(application_form.passport_expiry_date).to eq(
        Date.new(2.years.from_now.year, 1, 1),
      )
    end
  end

  describe "#expiry_date_in_the_past?" do
    context "when passport expiry date is in the past" do
      let(:passport_expiry_date) { { 1 => 2.years.ago.year, 2 => 1, 3 => 1 } }

      it "returns true" do
        expect(form.expiry_date_in_the_past?).to be true
      end
    end

    context "when passport expiry date is today" do
      let(:passport_expiry_date) do
        {
          1 => Date.current.year,
          2 => Date.current.month,
          3 => Date.current.day,
        }
      end

      it "returns false" do
        expect(form.expiry_date_in_the_past?).to be false
      end
    end

    context "when passport expiry date is in the future" do
      let(:passport_expiry_date) do
        { 1 => 2.years.from_now.year, 2 => 1, 3 => 1 }
      end

      it "returns false" do
        expect(form.expiry_date_in_the_past?).to be false
      end
    end

    context "when passport expiry date is nil" do
      let(:passport_expiry_date) { nil }

      it "returns false" do
        expect(form.expiry_date_in_the_past?).to be false
      end
    end

    context "when passport expiry date is already in a date format" do
      let(:passport_expiry_date) { 2.years.ago.to_date }

      it "returns true or false without any errors" do
        expect(form.expiry_date_in_the_past?).to be true
      end
    end
  end
end
