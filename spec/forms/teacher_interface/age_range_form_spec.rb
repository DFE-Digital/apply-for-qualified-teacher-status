# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::AgeRangeForm, type: :model do
  subject(:form) { described_class.new(application_form:, minimum:, maximum:) }

  let(:application_form) { build(:application_form) }

  describe "validations" do
    let(:minimum) { "" }
    let(:maximum) { "" }

    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:minimum) }
    it { is_expected.to validate_presence_of(:maximum) }

    context "with a minimum too low" do
      let(:minimum) { "1" }

      it { is_expected.to be_invalid }
    end

    context "with a minimum too high" do
      let(:minimum) { "20" }

      it { is_expected.to be_invalid }
    end

    context "when minimum is set" do
      let(:minimum) { "7" }

      context "with a maximum too low" do
        let(:minimum) { "1" }

        it { is_expected.to be_invalid }
      end

      context "with a maximum too high" do
        let(:minimum) { "20" }

        it { is_expected.to be_invalid }
      end
    end
  end

  describe "#save" do
    let(:minimum) { "7" }
    let(:maximum) { "11" }

    before { form.save(validate: true) }

    it "saves the application form" do
      expect(application_form.age_range_min).to eq(7)
      expect(application_form.age_range_max).to eq(11)
    end
  end
end
