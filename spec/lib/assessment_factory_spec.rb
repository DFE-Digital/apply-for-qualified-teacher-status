# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessmentFactory do
  let(:application_form) do
    create(
      :application_form,
      needs_work_history: false,
      needs_written_statement: false,
      needs_registration_number: false,
      age_range_min: 7,
      age_range_max: 11,
    )
  end

  describe "#call" do
    subject(:call) { described_class.call(application_form:) }

    it "creates an assessment" do
      expect { call }.to change(Assessment, :count).by(1)
    end

    it "sets the fields" do
      assessment = call
      expect(assessment.unknown?).to be true
      expect(assessment.application_form).to eq(application_form)
      expect(assessment.age_range_min).to eq(7)
      expect(assessment.age_range_max).to eq(11)
    end

    describe "sections" do
      subject(:sections) { call.sections }

      it "creates two sections" do
        expect(sections.count).to eq(4)
      end

      describe "personal information section" do
        it "is created" do
          expect(sections.personal_information.count).to eq(1)
        end

        it "has the right checks and failure reasons" do
          section = sections.personal_information.first
          expect(section.checks).to eq(
            %w[
              identification_document_present
              duplicate_application
              applicant_already_qts
              applicant_already_dqt
            ],
          )
          expect(section.failure_reasons).to eq(
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

        context "with a name change document" do
          before { application_form.update!(has_alternative_name: true) }

          it "has the right checks and failure reasons" do
            section = sections.personal_information.first
            expect(section.checks).to include("name_change_document_present")
            expect(section.failure_reasons).to include(
              "name_change_document_illegible",
            )
          end
        end
      end

      describe "qualifications section" do
        it "is created" do
          expect(sections.qualifications.count).to eq(1)
        end

        it "has the right checks and failure reasons" do
          section = sections.qualifications.first

          expect(section.checks).to eq(
            %w[
              qualifications_meet_level_6_or_equivalent
              teaching_qualifications_completed_in_eligible_country
              qualified_in_mainstream_education
              has_teacher_qualification_certificate
              has_teacher_qualification_transcript
              has_university_degree_certificate
              has_university_degree_transcript
              has_additional_qualification_certificate
              has_additional_degree_transcript
            ],
          )

          expect(section.failure_reasons).to eq(
            %w[
              application_and_qualification_names_do_not_match
              teaching_qualifications_from_ineligible_country
              teaching_qualifications_not_at_required_level
              teaching_hours_not_fulfilled
              not_qualified_to_teach_mainstream
              qualifications_dont_match_subjects
              qualifications_dont_match_other_details
              teaching_certificate_illegible
              teaching_transcript_illegible
              degree_certificate_illegible
              degree_transcript_illegible
              additional_degree_certificate_illegible
              additional_degree_transcript_illegible
            ],
          )
        end

        context "with a new regulations application form" do
          let(:application_form) { create(:application_form, :new_regs) }

          it "has the right checks and failure reasons" do
            section = sections.qualifications.first

            expect(section.checks).to eq(
              %w[
                qualifications_meet_level_6_or_equivalent
                teaching_qualifications_completed_in_eligible_country
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

            expect(section.failure_reasons).to eq(
              %w[
                application_and_qualification_names_do_not_match
                teaching_qualifications_from_ineligible_country
                teaching_qualifications_not_at_required_level
                teaching_hours_not_fulfilled
                teaching_qualification_pedagogy
                teaching_qualification_1_year
                not_qualified_to_teach_mainstream
                qualifications_dont_match_subjects
                qualifications_dont_match_other_details
                teaching_certificate_illegible
                teaching_transcript_illegible
                degree_certificate_illegible
                degree_transcript_illegible
                additional_degree_certificate_illegible
                additional_degree_transcript_illegible
              ],
            )
          end
        end

        context "with an application form with subject criteria" do
          let(:application_form) do
            create(
              :application_form,
              region: create(:region, :in_country, country_code: "SG"),
            )
          end

          it "has the right checks and failure reasons" do
            section = sections.qualifications.first

            expect(section.checks).to eq(
              %w[
                qualifications_meet_level_6_or_equivalent
                teaching_qualifications_completed_in_eligible_country
                qualified_in_mainstream_education
                qualified_to_teach_children_11_to_16
                teaching_qualification_subjects_criteria
                has_teacher_qualification_certificate
                has_teacher_qualification_transcript
                has_university_degree_certificate
                has_university_degree_transcript
                has_additional_qualification_certificate
                has_additional_degree_transcript
              ],
            )

            expect(section.failure_reasons).to eq(
              %w[
                application_and_qualification_names_do_not_match
                teaching_qualifications_from_ineligible_country
                teaching_qualifications_not_at_required_level
                teaching_hours_not_fulfilled
                not_qualified_to_teach_mainstream
                qualifications_dont_match_subjects
                qualifications_dont_match_other_details
                qualified_to_teach_children_11_to_16
                teaching_qualification_subjects_criteria
                teaching_certificate_illegible
                teaching_transcript_illegible
                degree_certificate_illegible
                degree_transcript_illegible
                additional_degree_certificate_illegible
                additional_degree_transcript_illegible
              ],
            )
          end
        end
      end

      describe "age range and subjects section" do
        it "is created" do
          expect(sections.age_range_subjects.count).to eq(1)
        end

        it "has the right checks and failure reasons" do
          section = sections.age_range_subjects.first
          expect(section.checks).to eq(
            %w[qualified_in_mainstream_education age_range_subjects_matches],
          )
          expect(section.failure_reasons).to eq(
            %w[not_qualified_to_teach_mainstream age_range],
          )
        end

        context "with an application form with subject criteria" do
          let(:application_form) do
            create(
              :application_form,
              region: create(:region, :in_country, country_code: "SG"),
            )
          end

          it "has the right checks and failure reasons" do
            section = sections.age_range_subjects.first

            expect(section.checks).to eq(
              %w[
                qualified_in_mainstream_education
                qualified_to_teach_children_11_to_16
                teaching_qualification_subjects_criteria
                age_range_subjects_matches
              ],
            )

            expect(section.failure_reasons).to eq(
              %w[not_qualified_to_teach_mainstream age_range],
            )
          end
        end
      end

      describe "work history section" do
        it "is not created" do
          expect(sections.work_history.count).to eq(0)
        end

        context "when application form form needs work history" do
          before { application_form.needs_work_history = true }

          it "is created" do
            expect(sections.work_history.count).to eq(1)
          end

          it "has the right checks and failure reasons" do
            section = sections.work_history.first
            expect(section.checks).to eq(
              %w[
                email_contact_current_employer
                satisfactory_evidence_work_history
              ],
            )
            expect(section.failure_reasons).to eq(
              ["satisfactory_evidence_work_history"],
            )
          end
        end

        context "with a new regulations application form" do
          let(:application_form) { create(:application_form, :new_regs) }

          before(:all) do
            FeatureFlags::FeatureFlag.activate(:application_work_history)
          end
          after(:all) do
            FeatureFlags::FeatureFlag.deactivate(:application_work_history)
          end

          it "has the right checks and failure reasons" do
            section = sections.work_history.first

            expect(section.checks).to eq(
              %w[verify_school_details work_history_references],
            )

            expect(section.failure_reasons).to eq(
              %w[work_history_break school_details_cannot_be_verified],
            )
          end
        end
      end

      describe "professional standing section" do
        it "is not created" do
          expect(sections.work_history.count).to eq(0)
        end

        context "when application form needs a written statement" do
          before { application_form.needs_written_statement = true }

          it "is created" do
            expect(sections.professional_standing.count).to eq(1)
          end

          it "has the right checks and failure reasons" do
            section = sections.professional_standing.first
            expect(section.checks).to eq(
              %w[
                written_statement_present
                written_statement_recent
                authorisation_to_teach
                teaching_qualification
                confirm_age_range_subjects
                qualified_to_teach
                full_professional_status
              ],
            )
            expect(section.failure_reasons).to eq(
              %w[
                written_statement_illegible
                written_statement_recent
                authorisation_to_teach
                teaching_qualification
                confirm_age_range_subjects
                qualified_to_teach
                full_professional_status
              ],
            )
          end
        end

        context "when application form needs a registration number" do
          before { application_form.needs_registration_number = true }

          it "is created" do
            expect(sections.professional_standing.count).to eq(1)
          end

          it "has the right checks and failure reasons" do
            section = sections.professional_standing.first
            expect(section.checks).to eq(
              %w[
                registration_number
                authorisation_to_teach
                teaching_qualification
                confirm_age_range_subjects
                qualified_to_teach
                full_professional_status
              ],
            )
            expect(section.failure_reasons).to eq(
              %w[
                registration_number
                authorisation_to_teach
                teaching_qualification
                confirm_age_range_subjects
                qualified_to_teach
                full_professional_status
              ],
            )
          end
        end
      end
    end
  end
end
