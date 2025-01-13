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

      context "when the expiry date is in the past" do
        let(:passport_expiry_date) { { 1 => 2.years.ago.year, 2 => 1, 3 => 1 } }

        it do
          expect(subject).to eq(
            ["The passport expiry date must be in the future."],
          )
        end
      end

      context "when expiry date has a 2 digit year" do
        let(:passport_expiry_date) { { 1 => 80, 2 => 1, 3 => 1 } }

        it do
          expect(subject).to eq(
            [
              "The passport expiry date must be entered as numbers, including the day, month and year. For example, 27 3 2007.",
            ],
          )
        end
      end

      context "when expiry date is an invalid date" do
        let(:passport_expiry_date) { { 1 => 1990, 2 => 13, 3 => 40 } }

        it do
          expect(subject).to eq(
            [
              "The passport expiry date must be entered as numbers, including the day, month and year. For example, 27 3 2007.",
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
end
