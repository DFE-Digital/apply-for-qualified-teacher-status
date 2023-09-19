# frozen_string_literal: true

require "rails_helper"

RSpec.describe PreliminaryAssessmentSectionsFactory do
  let(:application_form) { create(:application_form) }

  describe "#call" do
    before { create(:country, code: "SG", subject_limited: true) }
    subject(:assessment_sections) { described_class.call(application_form:) }

    it { is_expected.to be_empty }

    context "when application form requires a preliminary check" do
      let(:application_form) do
        create(
          :application_form,
          :requires_preliminary_check,
          region: create(:region, :in_country, country_code: "FR"),
        )
      end

      it { is_expected.to_not be_empty }

      let(:section) { assessment_sections.first }

      it "has the right checks and failure reasons" do
        expect(section.checks).to be_empty
        expect(section.failure_reasons).to eq(
          %w[teaching_qualifications_not_at_required_level],
        )
      end

      context "with an application form with subject criteria" do
        let(:application_form) do
          create(
            :application_form,
            :requires_preliminary_check,
            region: create(:region, :in_country, country_code: "SG"),
          )
        end

        it "has the right checks and failure reasons" do
          expect(section.checks).to eq(
            %w[
              qualifications_meet_level_6_or_equivalent
              teaching_qualification_subjects_criteria
            ],
          )
          expect(section.failure_reasons).to eq(
            %w[
              teaching_qualifications_not_at_required_level
              teaching_qualification_subjects_criteria
            ],
          )
        end
      end
    end
  end
end
