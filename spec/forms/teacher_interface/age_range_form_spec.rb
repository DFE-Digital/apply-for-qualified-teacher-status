require "rails_helper"

RSpec.describe TeacherInterface::AgeRangeForm, type: :model do
  let(:application_form) { build(:application_form) }

  subject(:form) { described_class.new(application_form:, minimum:, maximum:) }

  describe "validations" do
    let(:minimum) { "" }
    let(:maximum) { "" }

    it { is_expected.to validate_presence_of(:application_form) }

    it { is_expected.to validate_presence_of(:minimum) }
    it do
      is_expected.to validate_numericality_of(
        :minimum,
      ).only_integer.is_greater_than_or_equal_to(0)
    end

    it { is_expected.to validate_presence_of(:maximum) }

    context "when minimum is set" do
      let(:minimum) { "7" }
      it do
        is_expected.to validate_numericality_of(
          :maximum,
        ).only_integer.is_greater_than_or_equal_to(7)
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
