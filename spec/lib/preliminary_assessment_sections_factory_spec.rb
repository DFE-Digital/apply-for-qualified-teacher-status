# frozen_string_literal: true

require "rails_helper"

RSpec.describe PreliminaryAssessmentSectionsFactory do
  describe "#call" do
    subject(:assessment_sections) { described_class.call(application_form:) }

    context "when the application form doesn't require a preliminary check" do
      let(:application_form) { create(:application_form) }

      it { is_expected.to be_empty }
    end

    context "when the application form requires a preliminary check" do
      let(:application_form) do
        create(:application_form, :requires_preliminary_check)
      end

      let(:section) { assessment_sections.first }

      it { is_expected.not_to be_empty }

      it "has the right checks and failure reasons" do
        expect(section.checks).to be_empty
        expect(section.failure_reasons).to eq(
          %w[teaching_qualifications_not_at_required_level],
        )
      end

      context "and the country is subject limited" do
        let(:country) { create(:country, :subject_limited, code: "SG") }

        let(:application_form) do
          create(
            :application_form,
            :requires_preliminary_check,
            region: create(:region, country:),
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
