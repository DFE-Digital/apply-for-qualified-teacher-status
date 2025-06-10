# frozen_string_literal: true

# == Schema Information
#
# Table name: application_forms
#
#  id                                            :bigint           not null, primary key
#  action_required_by                            :string           default("none"), not null
#  age_range_max                                 :integer
#  age_range_min                                 :integer
#  age_range_status                              :string           default("not_started"), not null
#  alternative_family_name                       :text             default(""), not null
#  alternative_given_names                       :text             default(""), not null
#  awarded_at                                    :datetime
#  confirmed_no_sanctions                        :boolean          default(FALSE)
#  date_of_birth                                 :date
#  declined_at                                   :datetime
#  english_language_citizenship_exempt           :boolean
#  english_language_proof_method                 :string
#  english_language_provider_other               :boolean          default(FALSE), not null
#  english_language_provider_reference           :text             default(""), not null
#  english_language_qualification_exempt         :boolean
#  english_language_status                       :string           default("not_started"), not null
#  family_name                                   :text             default(""), not null
#  given_names                                   :text             default(""), not null
#  has_alternative_name                          :boolean
#  has_work_history                              :boolean
#  identification_document_status                :string           default("not_started"), not null
#  includes_prioritisation_features              :boolean          default(FALSE), not null
#  needs_registration_number                     :boolean          not null
#  needs_work_history                            :boolean          not null
#  needs_written_statement                       :boolean          not null
#  passport_country_of_issue_code                :string
#  passport_document_status                      :string           default("not_started"), not null
#  passport_expiry_date                          :date
#  personal_information_status                   :string           default("not_started"), not null
#  qualification_changed_work_history_duration   :boolean          default(FALSE), not null
#  qualifications_status                         :string           default("not_started"), not null
#  reduced_evidence_accepted                     :boolean          default(FALSE), not null
#  reference                                     :string(31)       not null
#  registration_number                           :text
#  registration_number_status                    :string           default("not_started"), not null
#  requires_passport_as_identity_proof           :boolean          default(FALSE), not null
#  requires_preliminary_check                    :boolean          default(FALSE), not null
#  stage                                         :string           default("draft"), not null
#  statuses                                      :string           default(["draft"]), not null, is an Array
#  subject_limited                               :boolean          default(FALSE), not null
#  subjects                                      :text             default([]), not null, is an Array
#  subjects_status                               :string           default("not_started"), not null
#  submitted_at                                  :datetime
#  teaching_authority_provides_written_statement :boolean          default(FALSE), not null
#  teaching_qualification_part_of_degree         :boolean
#  trs_match                                     :jsonb
#  withdrawn_at                                  :datetime
#  work_history_status                           :string           default("not_started"), not null
#  working_days_between_submitted_and_completed  :integer
#  working_days_between_submitted_and_today      :integer
#  written_statement_confirmation                :boolean          default(FALSE), not null
#  written_statement_optional                    :boolean          default(FALSE), not null
#  written_statement_status                      :string           default("not_started"), not null
#  created_at                                    :datetime         not null
#  updated_at                                    :datetime         not null
#  assessor_id                                   :bigint
#  english_language_provider_id                  :bigint
#  region_id                                     :bigint           not null
#  reviewer_id                                   :bigint
#  teacher_id                                    :bigint           not null
#
# Indexes
#
#  index_application_forms_on_action_required_by            (action_required_by)
#  index_application_forms_on_assessor_id                   (assessor_id)
#  index_application_forms_on_english_language_provider_id  (english_language_provider_id)
#  index_application_forms_on_family_name                   (family_name)
#  index_application_forms_on_given_names                   (given_names)
#  index_application_forms_on_reference                     (reference) UNIQUE
#  index_application_forms_on_region_id                     (region_id)
#  index_application_forms_on_reviewer_id                   (reviewer_id)
#  index_application_forms_on_stage                         (stage)
#  index_application_forms_on_teacher_id                    (teacher_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessor_id => staff.id)
#  fk_rails_...  (english_language_provider_id => english_language_providers.id)
#  fk_rails_...  (region_id => regions.id)
#  fk_rails_...  (reviewer_id => staff.id)
#  fk_rails_...  (teacher_id => teachers.id)
#
FactoryBot.define do
  factory :application_form do
    sequence(:reference) { |n| n.to_s.rjust(7, "0") }

    teacher
    region

    needs_work_history { !region.application_form_skip_work_history }
    needs_written_statement do
      region.status_check_written? || region.sanction_check_written?
    end
    needs_registration_number do
      region.status_check_online? || region.sanction_check_online?
    end
    reduced_evidence_accepted { region.reduced_evidence_accepted }
    written_statement_optional { region.written_statement_optional }
    requires_preliminary_check { region.requires_preliminary_check }
    subject_limited { region.country.subject_limited }
    teaching_authority_provides_written_statement do
      region.teaching_authority_provides_written_statement
    end

    trait :requires_preliminary_check do
      requires_preliminary_check { true }
    end

    trait :subject_limited do
      subject_limited { true }
    end

    trait :teaching_authority_provides_written_statement do
      teaching_authority_provides_written_statement { true }
    end

    trait :action_required_by_admin do
      action_required_by { "admin" }
    end

    trait :action_required_by_assessor do
      action_required_by { "assessor" }
    end

    trait :action_required_by_external do
      action_required_by { "external" }
    end

    trait :action_required_by_none do
      action_required_by { "none" }
    end

    trait :draft_stage do
      stage { "draft" }
      action_required_by_none
    end

    trait :pre_assessment_stage do
      stage { "pre_assessment" }
      action_required_by_admin
    end

    trait :not_started_stage do
      stage { "not_started" }
      action_required_by_assessor
    end

    trait :assessment_stage do
      stage { "assessment" }
      action_required_by_assessor
    end

    trait :verification_stage do
      stage { "verification" }
      action_required_by_admin
    end

    trait :review_stage do
      stage { "review" }
      action_required_by_assessor
    end

    trait :completed_stage do
      stage { "completed" }
      action_required_by_none
    end

    trait :submitted do
      not_started_stage
      statuses { %w[assessment_not_started] }
      submitted_at { Time.zone.now }
      working_days_between_submitted_and_today { 0 }
    end

    trait :preliminary_check do
      submitted
      pre_assessment_stage
      requires_preliminary_check
      statuses { %w[preliminary_check] }
    end

    trait :assessment_in_progress do
      submitted
      assessment_stage
      statuses { %w[assessment_in_progress] }
    end

    trait :awarded_pending_checks do
      submitted
      review_stage
      statuses { %w[awarded_pending_checks] }
    end

    trait :potential_duplicate_in_dqt do
      submitted
      review_stage
      statuses { %w[potential_duplicate_in_dqt] }
    end

    trait :awarded do
      submitted
      completed_stage
      statuses { %w[awarded] }
      awarded_at { Time.zone.now }
    end

    trait :declined do
      submitted
      completed_stage
      statuses { %w[declined] }
      declined_at { Time.zone.now }
    end

    trait :withdrawn do
      submitted
      completed_stage
      statuses { %w[withdrawn] }
      withdrawn_at { Time.zone.now }
    end

    trait :old_regulations do
      created_at { Date.new(2023, 1, 31) }
      needs_work_history do
        (region.status_check_none? || region.sanction_check_none?) &&
          !region.application_form_skip_work_history
      end
    end

    trait :with_assessment do
      after(:create) do |application_form, _evaluator|
        create(:assessment, application_form:)
      end
    end

    trait :with_personal_information do
      given_names { Faker::Name.name }
      family_name { Faker::Name.last_name }
      date_of_birth do
        Faker::Date.between(from: 65.years.ago, to: 21.years.ago)
      end
      has_alternative_name { false }
      personal_information_status { "completed" }
    end

    trait :with_identification_document do
      identification_document_status { "completed" }
      after(:create) do |application_form, _evaluator|
        create(
          :upload,
          :clean,
          document: application_form.identification_document,
        )
      end
    end

    trait :with_passport_document do
      requires_passport_as_identity_proof { true }
      passport_document_status { "completed" }

      passport_country_of_issue_code { "FRA" }
      passport_expiry_date { Date.new(2.years.from_now.year, 1, 1) }
      after(:create) do |application_form, _evaluator|
        create(:upload, :clean, document: application_form.passport_document)
      end
    end

    trait :with_unsafe_passport_document do
      identification_document_status { "completed" }
      after(:create) do |application_form, _evaluator|
        create(:upload, :suspect, document: application_form.passport_document)
      end
    end

    trait :with_alternative_name do
      has_alternative_name { true }
      alternative_given_names { Faker::Name.name }
      alternative_family_name { Faker::Name.last_name }
      after(:create) do |application_form, _evaluator|
        create(:upload, :clean, document: application_form.name_change_document)
      end
    end

    trait :with_age_range do
      age_range_min { Faker::Number.between(from: 5, to: 11) }
      age_range_max { Faker::Number.between(from: age_range_min, to: 18) }
      age_range_status { "completed" }
    end

    trait :with_subjects do
      transient { number_of_subjects { Faker::Number.between(from: 1, to: 3) } }

      subjects do
        ([-> { Faker::Educator.subject }] * number_of_subjects).map(&:call)
      end

      subjects_status { "completed" }
    end

    trait :with_teaching_qualification do
      teaching_qualification_part_of_degree { true }
      qualifications_status { "completed" }

      after(:create) do |application_form, _evaluator|
        create(
          :qualification,
          :completed,
          application_form:,
          institution_country_code: application_form.country.code,
        )
      end
    end

    trait :with_degree_qualification do
      with_teaching_qualification
      after(:create) do |application_form, _evaluator|
        create(:qualification, :completed, application_form:)
      end
    end

    trait :with_english_language_medium_of_instruction do
      english_language_citizenship_exempt { false }
      english_language_qualification_exempt { false }
      english_language_proof_method { "medium_of_instruction" }
      english_language_status { "completed" }

      after(:create) do |application_form, _evaluator|
        create(
          :upload,
          :clean,
          document:
            application_form.english_language_medium_of_instruction_document,
        )
      end
    end

    trait :with_english_language_esol do
      english_language_citizenship_exempt { false }
      english_language_qualification_exempt { false }
      english_language_proof_method { "esol" }
      english_language_status { "completed" }

      after(:create) do |application_form, _evaluator|
        create(
          :upload,
          :clean,
          document:
            application_form.english_for_speakers_of_other_languages_document,
        )
      end
    end

    trait :with_english_language_proficiency_document do
      with_english_language_provider

      after(:create) do |application_form, _evaluator|
        create(
          :upload,
          :clean,
          document: application_form.english_language_proficiency_document,
        )
      end
    end

    trait :with_english_language_provider do
      english_language_citizenship_exempt { false }
      english_language_qualification_exempt { false }
      english_language_proof_method { "provider" }
      english_language_provider do
        EnglishLanguageProvider.all.sample || create(:english_language_provider)
      end
      english_language_provider_reference { "reference" }
      english_language_status { "completed" }
    end

    trait :with_english_language_other_provider do
      english_language_citizenship_exempt { false }
      english_language_qualification_exempt { false }
      english_language_proof_method { "provider" }
      english_language_provider_other { true }
      english_language_status { "completed" }

      after(:create) do |application_form, _evaluator|
        create(
          :upload,
          :clean,
          document: application_form.english_language_proficiency_document,
        )
      end
    end

    trait :with_english_language_exemption_by_citizenship do
      english_language_citizenship_exempt { true }
      english_language_status { "completed" }
    end

    trait :with_english_language_exemption_by_qualification do
      english_language_citizenship_exempt { false }
      english_language_qualification_exempt { true }
      english_language_status { "completed" }
    end

    trait :with_work_history do
      needs_work_history { true }
      has_work_history { true }
      work_history_status { "completed" }

      after(:create) do |application_form, _evaluator|
        create(:work_history, :completed, :still_employed, application_form:)
        create(
          :work_history,
          :completed,
          :not_still_employed,
          application_form:,
        )
      end
    end

    trait :with_written_statement do
      needs_written_statement { true }
      written_statement_status { "completed" }

      after(:create) do |application_form, _evaluator|
        if application_form.teaching_authority_provides_written_statement
          application_form.update!(written_statement_confirmation: true)
        else
          create(
            :upload,
            :clean,
            document: application_form.written_statement_document,
          )
        end
      end
    end

    trait :with_registration_number do
      needs_registration_number { true }
      registration_number do
        Faker::Number.unique.leading_zero_number(digits: 8)
      end
      registration_number_status { "completed" }
    end

    factory :draft_application_form, traits: %i[draft_stage]
    factory :submitted_application_form, traits: %i[submitted]
  end
end
