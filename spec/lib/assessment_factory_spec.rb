# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessmentFactory do
  let(:country) { create(:country) }
  let(:application_form) do
    create(
      :application_form,
      region: create(:region, country:),
      needs_work_history: false,
      needs_written_statement: false,
      needs_registration_number: false,
      age_range_min: 7,
      age_range_max: 11,
      requires_passport_as_identity_proof:,
      english_language_citizenship_exempt:,
      english_language_qualification_exempt:,
    )
  end

  let(:requires_passport_as_identity_proof) { false }
  let(:english_language_citizenship_exempt) { false }
  let(:english_language_qualification_exempt) { false }

  before { FeatureFlags::FeatureFlag.activate(:suitability) }

  after { FeatureFlags::FeatureFlag.deactivate(:suitability) }

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

      it "creates four sections" do
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
              suitability
              suitability_previously_declined
              fraud
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

        context "with english language citizenship exemption" do
          let(:english_language_citizenship_exempt) { true }

          it "has the english exemption by citizenship unconfirmed failure reason" do
            section = sections.personal_information.first
            expect(section.failure_reasons).to include(
              "english_language_exemption_by_citizenship_not_confirmed",
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
              special_education_only
              suitability
              suitability_previously_declined
              fraud
            ],
          )
        end

        context "when secondary education teaching qualification is required" do
          before { application_form.subject_limited = true }

          it "has the right checks and failure reasons" do
            section = sections.qualifications.first

            expect(section.checks).to eq(
              %w[
                qualifications_meet_level_6_or_equivalent
                qualified_in_mainstream_education
                qualified_to_teach_children_11_to_16
                teaching_qualification_subjects_criteria
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
                qualified_to_teach_children_11_to_16
                teaching_qualification_subjects_criteria
                teaching_certificate_illegible
                teaching_transcript_illegible
                degree_certificate_illegible
                degree_transcript_illegible
                additional_degree_certificate_illegible
                additional_degree_transcript_illegible
                special_education_only
                suitability
                suitability_previously_declined
                fraud
              ],
            )
          end
        end

        context "when the applicant is exempt for english languaged due to qualification country" do
          let(:english_language_qualification_exempt) { true }

          it "has the right checks and failure reasons" do
            section = sections.qualifications.first

            expect(section.checks).to eq(
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

            expect(section.failure_reasons).to eq(
              %w[
                application_and_qualification_names_do_not_match
                teaching_qualifications_from_ineligible_country
                teaching_qualifications_not_at_required_level
                teaching_hours_not_fulfilled
                teaching_qualification_pedagogy
                teaching_qualification_1_year
                english_language_exemption_by_qualification_not_confirmed
                english_language_not_exempt_by_qualification_country
                not_qualified_to_teach_mainstream
                qualifications_dont_match_subjects
                qualifications_dont_match_other_details
                teaching_certificate_illegible
                teaching_transcript_illegible
                degree_certificate_illegible
                degree_transcript_illegible
                additional_degree_certificate_illegible
                additional_degree_transcript_illegible
                special_education_only
                suitability
                suitability_previously_declined
                fraud
              ],
            )
          end
        end
      end

      describe "age range and subjects section" do
        it "is created" do
          expect(sections.age_range_subjects.count).to eq(1)
        end

        context "when secondary education teaching qualification is not required" do
          it "has the right checks and failure reasons" do
            section = sections.age_range_subjects.first
            expect(section.checks).to eq(
              %w[qualified_in_mainstream_education age_range_subjects_matches],
            )
            expect(section.failure_reasons).to eq(
              %w[
                not_qualified_to_teach_mainstream
                age_range
                suitability
                suitability_previously_declined
                fraud
              ],
            )
          end
        end

        context "with an application form with subject criteria" do
          before { application_form.subject_limited = true }

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
              %w[
                not_qualified_to_teach_mainstream
                age_range
                suitability
                suitability_previously_declined
                fraud
              ],
            )
          end
        end
      end

      describe "preliminary qualifications section" do
        it "is not created" do
          expect(sections.preliminary.qualifications.count).to eq(0)
        end

        context "when application form requires a preliminary check" do
          before { application_form.requires_preliminary_check = true }

          it "is created" do
            expect(sections.preliminary.qualifications.count).to eq(1)
          end

          it "has the right checks and failure reasons" do
            section = sections.preliminary.qualifications.first
            expect(section.checks).to be_empty
            expect(section.failure_reasons).to eq(
              %w[teaching_qualifications_not_at_required_level],
            )
          end

          context "with an application form with subject criteria" do
            before { application_form.subject_limited = true }

            it "has the right checks and failure reasons" do
              section = sections.preliminary.qualifications.first

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

      describe "english language proficiency section" do
        let(:application_form) { create(:application_form) }

        it "is included in the task list when the EL feature is enabled" do
          expect(sections.english_language_proficiency.count).to eq(1)
        end
      end

      describe "work history section" do
        it "is not created" do
          expect(sections.work_history.count).to eq(0)
        end

        context "when an application requires work history" do
          before { application_form.needs_work_history = true }

          it "is created" do
            expect(sections.work_history.count).to eq(1)
          end

          it "has the right checks and failure reasons" do
            section = sections.work_history.first

            expect(section.checks).to eq(
              %w[verify_school_details work_history_references],
            )

            expect(section.failure_reasons).to eq(
              %w[
                work_history_break
                school_details_cannot_be_verified
                unrecognised_references
                work_history_duration
                suitability
                suitability_previously_declined
                fraud
              ],
            )
          end
        end
      end

      describe "professional standing section" do
        it "is not created" do
          expect(sections.professional_standing.count).to eq(0)
        end

        context "when application form needs a written statement and work history" do
          before do
            application_form.needs_written_statement = true
            application_form.needs_work_history = true
          end

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
                suitability
                suitability_previously_declined
                fraud
              ],
            )
          end
        end

        context "when application form needs a written statement and doesn't need work history" do
          before do
            application_form.needs_written_statement = true
            application_form.needs_work_history = false
          end

          it "is created" do
            expect(sections.professional_standing.count).to eq(1)
          end

          it "has the right checks and failure reasons" do
            section = sections.professional_standing.first
            expect(section.checks).to eq(
              %w[
                written_statement_present
                written_statement_recent
                written_statement_induction
                written_statement_completion_date
                written_statement_registration_number
                written_statement_school_name
                written_statement_signature
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
                written_statement_information
                authorisation_to_teach
                teaching_qualification
                confirm_age_range_subjects
                qualified_to_teach
                full_professional_status
                suitability
                suitability_previously_declined
                fraud
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
                registration_number_alternative
                authorisation_to_teach
                teaching_qualification
                confirm_age_range_subjects
                qualified_to_teach
                full_professional_status
                suitability
                suitability_previously_declined
                fraud
              ],
            )
          end
        end
      end
    end

    context "with application form requiring passport as identity proof" do
      let(:requires_passport_as_identity_proof) { true }

      describe "sections" do
        subject(:sections) { call.sections }

        describe "personal information section" do
          it "is created" do
            expect(sections.personal_information.count).to eq(1)
          end

          it "has the right checks and failure reasons" do
            section = sections.personal_information.first
            expect(section.checks).to eq(
              %w[
                expiry_date_valid
                passport_document_valid
                duplicate_application
                applicant_already_qts
                applicant_already_dqt
              ],
            )
            expect(section.failure_reasons).to eq(
              %w[
                passport_document_expired
                passport_document_illegible
                passport_document_mismatch
                duplicate_application
                applicant_already_qts
                applicant_already_dqt
                suitability
                suitability_previously_declined
                fraud
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

          context "with english language citizenship exemption (via passport)" do
            let(:english_language_citizenship_exempt) { true }

            it "has the english exemption by citizenship unconfirmed failure reason" do
              section = sections.personal_information.first
              expect(section.failure_reasons).to include(
                "english_language_exemption_by_citizenship_not_confirmed_via_passport",
              )
            end
          end
        end
      end
    end
  end
end
