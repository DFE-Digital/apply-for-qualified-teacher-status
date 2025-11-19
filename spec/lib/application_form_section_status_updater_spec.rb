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

      context "with all fields set and national insurance number" do
        let(:application_form) do
          create(
            :application_form,
            :with_personal_information,
            national_insurance_number:,
          )
        end

        let(:national_insurance_number) { "QQ123456A" }

        it { is_expected.to eq("completed") }

        context "when the national insurance number is invalid" do
          let(:national_insurance_number) { "QQ1A" }

          it { is_expected.to eq("in_progress") }
        end
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

    describe "passport document" do
      subject(:passport_document_status) do
        application_form.passport_document_status
      end

      context "without a passport document" do
        let(:application_form) { create(:application_form) }

        it "returns not_started" do
          application_form.passport_document.destroy!
          application_form.reload

          described_class.call(application_form:)

          expect(subject).to eq("not_started")
        end
      end

      context "with no upload or expiry date" do
        let(:application_form) { create(:application_form) }

        it { is_expected.to eq("not_started") }
      end

      context "with valid expiry date and country of issue but no upload" do
        let(:application_form) do
          create(
            :application_form,
            passport_country_of_issue_code: "FRA",
            passport_expiry_date: Date.new(2.years.from_now.year, 1, 1),
          )
        end

        it { is_expected.to eq("in_progress") }
      end

      context "with valid expiry date and an upload but no country of issue" do
        let(:application_form) do
          create(
            :application_form,
            :with_passport_document,
            passport_country_of_issue_code: nil,
          )
        end

        it { is_expected.to eq("in_progress") }
      end

      context "with valid expiry date, country of issue and an upload" do
        let(:application_form) do
          create(:application_form, :with_passport_document)
        end

        it { is_expected.to eq("completed") }
      end

      context "with valid expiry date and an unsafe upload" do
        let(:application_form) do
          create(
            :application_form,
            :with_unsafe_passport_document,
            passport_expiry_date: Date.new(2.years.from_now.year, 1, 1),
          )
        end

        it { is_expected.to eq("error") }
      end

      context "with invalid expiry date" do
        let(:application_form) do
          create(
            :application_form,
            :with_passport_document,
            passport_expiry_date: Date.new(2.years.ago.year, 1, 1),
          )
        end

        it { is_expected.to eq("in_progress") }
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

      context "with all complete qualifications and part of university degree" do
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

      context "when ESOL" do
        let(:application_form) do
          create(:application_form, english_language_proof_method: "esol")
        end

        it { is_expected.to eq("in_progress") }
      end

      context "when ESOL and uploaded" do
        let(:application_form) do
          create(:application_form, :with_english_language_esol)
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
            create(:work_history, application_form:, contact_email:)
          end
        end
        let(:contact_email) { "test@gmail.com" }

        it { is_expected.to eq("in_progress") }

        # TODO: Once all existing draft applications have gone through post release,
        # we no longer need to do this check on any of the above. This would mean that
        # all existing draft application have started_with_private_email_for_referee is true
        context "when private email domain for referee feature is enabled" do
          before do
            FeatureFlags::FeatureFlag.activate(:email_domains_for_referees)
            described_class.call(application_form:)
          end

          after do
            FeatureFlags::FeatureFlag.deactivate(:email_domains_for_referees)
          end

          it { is_expected.to eq("in_progress") }
        end
      end

      context "with a complete work history" do
        let(:application_form) do
          create(:application_form).tap do |application_form|
            create(:work_history, :completed, application_form:, contact_email:)
          end
        end
        let(:contact_email) { "test@gmail.com" }

        it { is_expected.to eq("completed") }

        # TODO: Once all existing draft applications have gone through post release,
        # we no longer need to do this check on any of the above. This would mean that
        # all existing draft application have started_with_private_email_for_referee is true
        context "when private email domain for referee feature is enabled" do
          before do
            FeatureFlags::FeatureFlag.activate(:email_domains_for_referees)
            described_class.call(application_form:)
          end

          after do
            FeatureFlags::FeatureFlag.deactivate(:email_domains_for_referees)
          end

          it { is_expected.to eq("update_needed") }

          context "with contact email having a private email domain" do
            let(:contact_email) { "test@private.com" }

            it { is_expected.to eq("completed") }
          end
        end

        context "when there is also other England work history role that is incomplete" do
          let(:application_form) do
            create(:application_form).tap do |application_form|
              create(:work_history, :completed, application_form:)
              create(:work_history, :other_england_role, application_form:)
            end
          end

          it { is_expected.to eq("completed") }
        end
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

    describe "other England work history" do
      subject(:other_england_work_history_status) do
        application_form.other_england_work_history_status
      end

      context "with has not answered whether they have other England work experience" do
        let(:application_form) { create(:application_form) }

        it { is_expected.to eq("not_started") }
      end

      context "with has no other England work history" do
        let(:application_form) do
          create(:application_form, has_other_england_work_history: false)
        end

        it { is_expected.to eq("completed") }
      end

      context "with has other England work history but no work history" do
        let(:application_form) do
          create(:application_form, has_other_england_work_history: true)
        end

        it { is_expected.to eq("in_progress") }
      end

      context "with an incomplete work history" do
        let(:application_form) do
          create(
            :application_form,
            has_other_england_work_history: true,
          ).tap do |application_form|
            create(
              :work_history,
              :other_england_role,
              application_form:,
              contact_email:,
            )
          end
        end
        let(:contact_email) { "test@gmail.com" }

        it { is_expected.to eq("in_progress") }

        # TODO: Once all existing draft applications have gone through post release,
        # we no longer need to do this check on any of the above. This would mean that
        # all existing draft application have started_with_private_email_for_referee is true
        context "when private email domain for referee feature is enabled" do
          before do
            FeatureFlags::FeatureFlag.activate(:email_domains_for_referees)
            described_class.call(application_form:)
          end

          after do
            FeatureFlags::FeatureFlag.deactivate(:email_domains_for_referees)
          end

          it { is_expected.to eq("in_progress") }
        end
      end

      context "with a complete work history" do
        let(:application_form) do
          create(
            :application_form,
            has_other_england_work_history: true,
          ).tap do |application_form|
            create(
              :work_history,
              :other_england_role,
              :completed,
              application_form:,
              contact_email:,
            )
          end
        end
        let(:contact_email) { "test@gmail.com" }

        it { is_expected.to eq("completed") }

        # TODO: Once all existing draft applications have gone through post release,
        # we no longer need to do this check on any of the above. This would mean that
        # all existing draft application have started_with_private_email_for_referee is true
        context "when private email domain for referee feature is enabled" do
          before do
            FeatureFlags::FeatureFlag.activate(:email_domains_for_referees)
            described_class.call(application_form:)
          end

          after do
            FeatureFlags::FeatureFlag.deactivate(:email_domains_for_referees)
          end

          it { is_expected.to eq("update_needed") }

          context "with contact email having a private email domain" do
            let(:contact_email) { "test@private.com" }

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

      context "when the application form is from Ghana" do
        let(:application_form) do
          create(
            :application_form,
            registration_number:,
            region: ghana_country.regions.first,
          )
        end
        let(:ghana_country) do
          create(:country, :with_national_region, code: "GH")
        end

        context "without a registration/license number" do
          let(:registration_number) { nil }

          it { is_expected.to eq("not_started") }
        end

        context "without a valid registration/license number" do
          let(:registration_number) { "P/12%3/44N" }

          it { is_expected.to eq("in_progress") }
        end

        context "with a valid registration/license number" do
          let(:registration_number) { "PT/123456/1234" }

          it { is_expected.to eq("completed") }
        end
      end
    end
  end
end
