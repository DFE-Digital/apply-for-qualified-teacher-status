# frozen_string_literal: true

require "rails_helper"

RSpec.describe SyncAssessmentChecksAndFailureReasonsJob do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(assessment) }

    let(:application_form) { create(:application_form, stage: :not_started) }
    let(:assessment) { create(:assessment, application_form:) }

    let!(:preliminary_assessment_section) do
      create :assessment_section, :preliminary
    end

    let!(:personal_information_assessment_section) do
      create :assessment_section,
             :personal_information,
             assessment:,
             checks: [],
             failure_reasons: []
    end

    let!(:qualifications_assessment_section) do
      create :assessment_section,
             :qualifications,
             assessment:,
             checks: [],
             failure_reasons: []
    end

    let!(:age_range_subjects_assessment_section) do
      create :assessment_section,
             :age_range_subjects,
             assessment:,
             checks: [],
             failure_reasons: []
    end

    let!(:english_language_proficiency_assessment_section) do
      create :assessment_section,
             :english_language_proficiency,
             assessment:,
             checks: [],
             failure_reasons: []
    end

    let!(:work_history_assessment_section) do
      create :assessment_section,
             :work_history,
             assessment:,
             checks: [],
             failure_reasons: []
    end

    let!(:professional_standing_assessment_section) do
      create :assessment_section,
             :professional_standing,
             assessment:,
             checks: [],
             failure_reasons: []
    end

    it "does not update the preliminary assessment section" do
      expect { perform }.not_to change(
        preliminary_assessment_section.reload,
        :updated_at,
      )
    end

    it "updates the checks and failure reasons on personal information" do
      perform

      personal_information_assessment_section.reload
      expect(personal_information_assessment_section.checks).to eq(
        %w[
          identification_document_present
          duplicate_application
          applicant_already_qts
          applicant_already_dqt
        ],
      )
      expect(personal_information_assessment_section.failure_reasons).to eq(
        %w[
          identification_document_expired
          identification_document_illegible
          identification_document_mismatch
          duplicate_application
          applicant_already_qts
          applicant_already_dqt
        ],
      )
    end

    it "updates the checks and failure reasons on qualifications" do
      perform

      qualifications_assessment_section.reload
      expect(qualifications_assessment_section.checks).to eq(
        %w[
          qualifications_meet_level_6_or_equivalent
          qualified_in_mainstream_education
          has_teacher_qualification_certificate
          has_teacher_qualification_transcript
          has_university_degree_certificate
          has_university_degree_transcript
          has_additional_qualification_certificate
          has_additional_degree_transcript
          teaching_qualification_pedagogy
          teaching_qualification_1_year
        ],
      )

      expect(qualifications_assessment_section.failure_reasons).to eq(
        %w[
          application_and_qualification_names_do_not_match
          qualifications_or_modules_required_not_provided
          teaching_qualifications_from_ineligible_country
          teaching_qualifications_not_at_required_level
          teaching_hours_not_fulfilled
          teaching_qualification_pedagogy
          teaching_qualification_1_year
          not_qualified_to_teach_mainstream
          qualifications_dont_match_other_details
          teaching_certificate_illegible
          teaching_transcript_illegible
          degree_certificate_illegible
          degree_transcript_illegible
          additional_degree_certificate_illegible
          additional_degree_transcript_illegible
          special_education_only
        ],
      )
    end

    it "updates the checks and failure reasons on age range subjects" do
      perform

      age_range_subjects_assessment_section.reload
      expect(age_range_subjects_assessment_section.checks).to eq(
        %w[qualified_in_mainstream_education age_range_subjects_matches],
      )
      expect(age_range_subjects_assessment_section.failure_reasons).to eq(
        %w[not_qualified_to_teach_mainstream age_range],
      )
    end

    it "updates the checks and failure reasons on English language proficiency" do
      perform

      english_language_proficiency_assessment_section.reload
      expect(english_language_proficiency_assessment_section.checks).to eq(
        %w[english_language_valid_provider],
      )
      expect(
        english_language_proficiency_assessment_section.failure_reasons,
      ).to eq(
        %w[
          english_language_qualification_invalid
          english_language_unverifiable_reference_number
          english_language_not_achieved_b2
          english_language_selt_expired
          english_language_proficiency_require_alternative
        ],
      )
    end

    it "updates the checks and failure reasons on work history" do
      perform

      work_history_assessment_section.reload
      expect(work_history_assessment_section.checks).to eq(
        %w[verify_school_details work_history_references],
      )
      expect(work_history_assessment_section.failure_reasons).to eq(
        %w[
          work_history_break
          school_details_cannot_be_verified
          unrecognised_references
          work_history_duration
          work_history_information
        ],
      )
    end

    it "updates the checks and failure reasons on professional standing" do
      perform

      professional_standing_assessment_section.reload
      expect(professional_standing_assessment_section.checks).to eq(
        %w[
          authorisation_to_teach
          teaching_qualification
          confirm_age_range_subjects
          qualified_to_teach
          full_professional_status
        ],
      )
      expect(professional_standing_assessment_section.failure_reasons).to eq(
        %w[
          authorisation_to_teach
          teaching_qualification
          confirm_age_range_subjects
          qualified_to_teach
          full_professional_status
        ],
      )
    end

    context "when the application is already in progress for assessment" do
      let(:application_form) { create(:application_form, stage: :assessment) }

      it "raises AssessmentAlreadyInProgress" do
        expect { perform }.to raise_error(
          SyncAssessmentChecksAndFailureReasonsJob::AssessmentAlreadyInProgress,
        )
      end
    end
  end
end
