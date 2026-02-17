# frozen_string_literal: true

require "rails_helper"

RSpec.describe EligibilityInterface::TeachChildrenForm, type: :model do
  describe "#valid?" do
    subject(:valid) { form.valid? }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) { described_class.new(eligibility_check:, teach_children:) }
    let(:teach_children) { "true" }

    it { is_expected.to be_truthy }
    it { expect(form).to validate_presence_of(:eligibility_check) }

    context "when teach_children is blank" do
      let(:teach_children) { "" }

      it { is_expected.to be_falsy }

      it "returns the error message" do
        valid
        expect(form.errors[:teach_children]).to include(
          "Select if you are qualified to teach children aged between 5 and 16",
        )
      end

      context "with qualification being subject limited" do
        let(:eligibility_check) do
          create(:eligibility_check, country_code: subject_limited_country.code)
        end
        let(:subject_limited_country) { create(:country, :subject_limited) }

        it "returns the error message" do
          valid
          expect(form.errors[:teach_children]).to include(
            "Select if you are qualified to teach children aged between 11 and 16",
          )
        end

        context "when has eligible work experience in England" do
          let(:eligibility_check) do
            create(
              :eligibility_check,
              country_code: subject_limited_country.code,
              eligible_work_experience_in_england: true,
            )
          end

          it "returns the error message" do
            valid
            expect(form.errors[:teach_children]).to include(
              "Select if you are qualified to teach children aged between 5 and 16",
            )
          end
        end
      end
    end
  end

  describe "#save" do
    subject(:save!) { form.save }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) { described_class.new(eligibility_check:, teach_children: true) }

    it "saves the eligibility check" do
      save!
      expect(eligibility_check.teach_children).to be_truthy
    end
  end
end
