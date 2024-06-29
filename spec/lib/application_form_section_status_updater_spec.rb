# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationFormSectionStatusUpdater do
  describe "#call" do
    before { described_class.call(application_form:) }

    describe "personal information" do
      subject(:personal_information_status) do
        application_form.personal_information_status
      end

      context "with no fields set" do
        let(:application_form) { create(:application_form) }

        it { is_expected.to eq("not_started") }
      end

      context "with some fields set" do
        let(:application_form) do
          create(:application_form, given_names: "Given")
        end

        it { is_expected.to eq("in_progress") }
      end

      context "with all fields set" do
        let(:application_form) do
          create(:application_form, :with_personal_information)
        end

        it { is_expected.to eq("completed") }
      end

      context "with all fields set and alternative name" do
        let(:application_form) do
          create(
            :application_form,
            :with_personal_information,
            :with_alternative_name,
          )
        end

        it { is_expected.to eq("completed") }
      end
    end

    describe "identification document" do
      subject(:identification_document_status) do
        application_form.identification_document_status
      end

      context "with no upload" do
        let(:application_form) { create(:application_form) }

        it { is_expected.to eq("not_started") }
      end

      context "with an upload" do
        let(:application_form) do
          create(:application_form, :with_identification_document)
        end

        it { is_expected.to eq("completed") }
      end
    end

    describe "qualifications" do
      subject(:qualifications_status) { application_form.qualifications_status }

      context "with no qualifications" do
        let(:application_form) { create(:application_form) }

        it { is_expected.to eq("not_started") }
      end

      context "with an incomplete qualification" do
        let(:application_form) do
          create(:application_form).tap do |application_form|
            create(:qualification, application_form:)
          end
        end

        it { is_expected.to eq("in_progress") }
      end

      context "with all complete qualifications and not part of university degree" do
        let(:application_form) do
          create(
            :application_form,
            teaching_qualification_part_of_degree: false,
          ).tap do |application_form|
            create(:qualification, :completed, application_form:)
            create(:qualification, :completed, application_form:)
          end
        end

        it { is_expected.to eq("completed") }
      end

      context "with an incomplete qualification" do
        let(:application_form) do
          create(
            :application_form,
            teaching_qualification_part_of_degree: true,
          ).tap do |application_form|
            create(:qualification, :completed, application_form:)
          end
        end

        it { is_expected.to eq("completed") }
      end
    end

    describe "age range" do
      subject(:age_range_status) { application_form.age_range_status }

      context "with no fields set" do
        let(:application_form) { create(:application_form) }

        it { is_expected.to eq("not_started") }
      end

      context "with some fields set" do
        let(:application_form) { create(:application_form, age_range_min: 7) }

        it { is_expected.to eq("in_progress") }
      end

      context "with all fields set" do
        let(:application_form) { create(:application_form, :with_age_range) }

        it { is_expected.to eq("completed") }
      end
    end

    describe "subjects" do
      subject(:subjects_status) { application_form.subjects_status }

      context "with no fields set" do
        let(:application_form) { create(:application_form) }

        it { is_expected.to eq("not_started") }
      end

      context "with some fields set" do
        let(:application_form) { create(:application_form, subjects: [""]) }

        it { is_expected.to eq("in_progress") }
      end

      context "with all fields set" do
        let(:application_form) { create(:application_form, :with_subjects) }

        it { is_expected.to eq("completed") }
      end
    end

    describe "english language" do
      subject(:english_language_status) do
        application_form.english_language_status
      end

      context "with no information provided yet" do
        let(:application_form) { create(:application_form) }

        it { is_expected.to eq("not_started") }
      end

      context "when exempt by citizenship" do
        let(:application_form) do
          create(:application_form, english_language_citizenship_exempt: true)
        end

        it { is_expected.to eq("completed") }
      end

      context "when exempt by qualification" do
        let(:application_form) do
          create(:application_form, english_language_qualification_exempt: true)
        end

        it { is_expected.to eq("completed") }
      end

      context "when not exempt" do
        let(:application_form) do
          create(
            :application_form,
            english_language_citizenship_exempt: false,
            english_language_qualification_exempt: false,
          )
        end

        it { is_expected.to eq("in_progress") }
      end

      context "when medium of instruction" do
        let(:application_form) do
          create(
            :application_form,
            english_language_proof_method: "medium_of_instruction",
          )
        end

        it { is_expected.to eq("in_progress") }
      end

      context "when medium of instruction and uploaded" do
        let(:application_form) do
          create(
            :application_form,
            :with_english_language_medium_of_instruction,
          )
        end

        it { is_expected.to eq("completed") }
      end

      context "when provider" do
        let(:application_form) do
          create(:application_form, english_language_proof_method: "provider")
        end

        it { is_expected.to eq("in_progress") }
      end

      context "when provider and reference given" do
        let(:application_form) do
          create(:application_form, :with_english_language_provider)
        end

        it { is_expected.to eq("completed") }
      end

      context "when other provider and uploaded" do
        let(:application_form) do
          create(:application_form, :with_english_language_proficiency_document)
        end

        it { is_expected.to eq("completed") }
      end
    end

    describe "work history" do
      subject(:work_history_status) { application_form.work_history_status }

      context "with has no work history" do
        let(:application_form) do
          create(:application_form, has_work_history: false)
        end

        it { is_expected.to eq("not_started") }
      end

      context "with has work history but no work history" do
        let(:application_form) do
          create(:application_form, has_work_history: true)
        end

        it { is_expected.to eq("not_started") }
      end

      context "with an incomplete work history" do
        let(:application_form) do
          create(:application_form).tap do |application_form|
            create(:work_history, application_form:)
          end
        end

        it { is_expected.to eq("in_progress") }
      end

      context "with a complete work history" do
        let(:application_form) do
          create(:application_form).tap do |application_form|
            create(:work_history, :completed, application_form:)
          end
        end

        it { is_expected.to eq("completed") }
      end

      context "under the old regulations" do
        context "with unknown work history" do
          let(:application_form) { create(:application_form, :old_regulations) }

          it { is_expected.to eq("not_started") }
        end

        context "with no work history" do
          let(:application_form) do
            create(:application_form, :old_regulations, has_work_history: false)
          end

          it { is_expected.to eq("completed") }
        end

        context "with has work history" do
          context "without work history" do
            let(:application_form) do
              create(
                :application_form,
                :old_regulations,
                has_work_history: true,
              )
            end

            it { is_expected.to eq("in_progress") }
          end

          context "with an incomplete work history" do
            let(:application_form) do
              create(
                :application_form,
                :old_regulations,
                has_work_history: true,
              ).tap do |application_form|
                create(:work_history, application_form:)
              end
            end

            it { is_expected.to eq("in_progress") }
          end

          context "with a complete work history" do
            let(:application_form) do
              create(
                :application_form,
                :old_regulations,
                has_work_history: true,
              ).tap do |application_form|
                create(:work_history, :completed, application_form:)
              end
            end

            it { is_expected.to eq("completed") }
          end
        end
      end
    end

    describe "written statement" do
      subject(:written_statement_status) do
        application_form.written_statement_status
      end

      context "when teaching authority provides the written statement" do
        context "without confirmation" do
          let(:application_form) do
            create(
              :application_form,
              :teaching_authority_provides_written_statement,
              :with_written_statement,
            )
          end

          it { is_expected.to eq("completed") }
        end

        context "with confirmation" do
          let(:application_form) do
            create(
              :application_form,
              :teaching_authority_provides_written_statement,
            )
          end

          it { is_expected.to eq("not_started") }
        end
      end

      context "when teacher provides the written statement" do
        context "with no upload" do
          let(:application_form) { create(:application_form) }

          it { is_expected.to eq("not_started") }
        end

        context "with an upload" do
          let(:application_form) do
            create(:application_form, :with_written_statement)
          end

          it { is_expected.to eq("completed") }
        end
      end
    end

    describe "registration number" do
      subject(:registration_number_status) do
        application_form.registration_number_status
      end

      context "without a registration number" do
        let(:application_form) { create(:application_form) }

        it { is_expected.to eq("not_started") }
      end

      context "with a registration number" do
        let(:application_form) do
          create(:application_form, :with_registration_number)
        end

        it { is_expected.to eq("completed") }
      end
    end
  end
end
