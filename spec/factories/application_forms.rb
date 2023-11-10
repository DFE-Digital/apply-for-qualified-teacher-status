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
#  dqt_match                                     :jsonb
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
#  needs_registration_number                     :boolean          not null
#  needs_work_history                            :boolean          not null
#  needs_written_statement                       :boolean          not null
#  overdue_further_information                   :boolean          default(FALSE), not null
#  overdue_professional_standing                 :boolean          default(FALSE), not null
#  overdue_qualification                         :boolean          default(FALSE), not null
#  overdue_reference                             :boolean          default(FALSE), not null
#  personal_information_status                   :string           default("not_started"), not null
#  qualifications_status                         :string           default("not_started"), not null
#  received_further_information                  :boolean          default(FALSE), not null
#  received_professional_standing                :boolean          default(FALSE), not null
#  received_qualification                        :boolean          default(FALSE), not null
#  received_reference                            :boolean          default(FALSE), not null
#  reduced_evidence_accepted                     :boolean          default(FALSE), not null
#  reference                                     :string(31)       not null
#  registration_number                           :text
#  registration_number_status                    :string           default("not_started"), not null
#  requires_preliminary_check                    :boolean          default(FALSE), not null
#  stage                                         :string           default("draft"), not null
#  status                                        :string           default("draft"), not null
#  statuses                                      :string           default(["\"draft\""]), not null, is an Array
#  subjects                                      :text             default([]), not null, is an Array
#  subjects_status                               :string           default("not_started"), not null
#  submitted_at                                  :datetime
#  teaching_authority_provides_written_statement :boolean          default(FALSE), not null
#  waiting_on_further_information                :boolean          default(FALSE), not null
#  waiting_on_professional_standing              :boolean          default(FALSE), not null
#  waiting_on_qualification                      :boolean          default(FALSE), not null
#  waiting_on_reference                          :boolean          default(FALSE), not null
#  withdrawn_at                                  :datetime
#  work_history_status                           :string           default("not_started"), not null
#  working_days_since_submission                 :integer
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
#  index_application_forms_on_status                        (status)
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
    status { "draft" }
    association :teacher
    association :region

    needs_work_history { !region.application_form_skip_work_history }
    needs_written_statement do
      region.status_check_written? || region.sanction_check_written?
    end
    needs_registration_number do
      region.status_check_online? || region.sanction_check_online?
    end
    reduced_evidence_accepted { region.reduced_evidence_accepted }
    written_statement_optional { region.written_statement_optional }
    teaching_authority_provides_written_statement do
      region.teaching_authority_provides_written_statement
    end
    requires_preliminary_check { region.requires_preliminary_check }

    trait :requires_preliminary_check do
      requires_preliminary_check { true }
    end

    trait :completed do
      personal_information_status { "completed" }
      identification_document_status { "completed" }
      qualifications_status { "completed" }
      age_range_status { "completed" }
      subjects_status { "completed" }
      english_language_status { "completed" }
      work_history_status { "completed" }
      registration_number_status { "completed" }
      written_statement_status { "completed" }
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
      status { "submitted" }
      statuses { %w[assessment_not_started] }
      submitted_at { Time.zone.now }
      working_days_since_submission { 0 }

      after(:create) do |application_form, _evaluator|
        create(
          :timeline_event,
          :stage_changed,
          application_form:,
          creator: application_form.teacher,
          old_value: "draft",
          new_value: "not_started",
        )
      end
    end

    trait :preliminary_check do
      submitted
      pre_assessment_stage
      requires_preliminary_check { true }
      status { "preliminary_check" }
      statuses { %w[preliminary_check] }
    end

    trait :assessment_in_progress do
      submitted
      assessment_stage
      status { "assessment_in_progress" }
      statuses { %w[assessment_in_progress] }
    end

    trait :waiting_on do
      submitted
      action_required_by_external
      verification_stage
      status { "waiting_on" }
      statuses do
        %w[
          waiting_on_further_information
          waiting_on_lops
          waiting_on_qualification
          waiting_on_reference
        ]
      end
    end

    trait :received do
      submitted
      verification_stage
      status { "received" }
      statuses do
        %w[
          received_further_information
          received_lops
          received_qualification
          received_reference
        ]
      end
    end

    trait :overdue do
      submitted
      verification_stage
      status { "overdue" }
      statuses do
        %w[
          overdue_further_information
          overdue_lops
          overdue_qualification
          overdue_reference
        ]
      end
    end

    trait :awarded_pending_checks do
      submitted
      review_stage
      status { "awarded_pending_checks" }
      statuses { %w[awarded_pending_checks] }
    end

    trait :potential_duplicate_in_dqt do
      submitted
      review_stage
      status { "potential_duplicate_in_dqt" }
      statuses { %w[potential_duplicate_in_dqt] }
    end

    trait :awarded do
      submitted
      completed_stage
      status { "awarded" }
      statuses { %w[awarded] }
      awarded_at { Time.zone.now }
    end

    trait :declined do
      submitted
      completed_stage
      status { "declined" }
      statuses { %w[declined] }
      declined_at { Time.zone.now }
    end

    trait :withdrawn do
      submitted
      completed_stage
      status { "withdrawn" }
      statuses { %w[withdrawn] }
      withdrawn_at { Time.zone.now }
    end

    trait :old_regs do
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

    trait :with_age_range do
      age_range_min { Faker::Number.between(from: 5, to: 11) }
      age_range_max { Faker::Number.between(from: age_range_min, to: 18) }
    end

    trait :with_subjects do
      transient { number_of_subjects { Faker::Number.between(from: 1, to: 3) } }

      subjects do
        ([-> { Faker::Educator.subject }] * number_of_subjects).map(&:call)
      end
    end

    trait :with_identification_document do
      after(:create) do |application_form, _evaluator|
        create(:upload, document: application_form.identification_document)
      end
    end

    trait :with_personal_information do
      given_names { Faker::Name.name }
      family_name { Faker::Name.last_name }
      date_of_birth do
        Faker::Date.between(from: 65.years.ago, to: 21.years.ago)
      end
      has_alternative_name { false }
    end

    trait :with_alternative_name do
      has_alternative_name { true }
      alternative_given_names { Faker::Name.name }
      alternative_family_name { Faker::Name.last_name }
    end

    trait :with_name_change_document do
      after(:create) do |application_form, _evaluator|
        create(:upload, document: application_form.name_change_document)
      end
    end

    trait :with_registration_number do
      needs_registration_number { true }
      registration_number do
        Faker::Number.unique.leading_zero_number(digits: 8)
      end
    end

    trait :with_completed_qualification do
      after(:create) do |application_form, _evaluator|
        create(
          :qualification,
          :completed,
          application_form:,
          institution_country_code: application_form.country.code,
        )
      end
    end

    trait :with_english_language_medium_of_instruction do
      english_language_proof_method { "medium_of_instruction" }

      after(:create) do |application_form, _evaluator|
        create(
          :upload,
          document:
            application_form.english_language_medium_of_instruction_document,
        )
      end
    end

    trait :with_english_language_proficiency_document do
      with_english_language_provider

      after(:create) do |application_form, _evaluator|
        create(
          :upload,
          document: application_form.english_language_proficiency_document,
        )
      end
    end

    trait :with_english_language_provider do
      english_language_proof_method { "provider" }
      english_language_provider do
        EnglishLanguageProvider.all.sample || create(:english_language_provider)
      end
      english_language_provider_reference { "reference" }
    end

    trait :with_english_language_other_provider do
      english_language_proof_method { "provider" }
      english_language_provider_other { true }

      after(:create) do |application_form, _evaluator|
        create(
          :upload,
          document: application_form.english_language_proficiency_document,
        )
      end
    end

    trait :with_english_language_exemption_by_citizenship do
      english_language_citizenship_exempt { true }
    end

    trait :with_english_language_exemption_by_qualification do
      english_language_qualification_exempt { true }
    end

    trait :with_work_history do
      needs_work_history { true }
      has_work_history { true }

      after(:create) do |application_form, _evaluator|
        create(:work_history, :completed, application_form:)
      end
    end

    trait :teaching_authority_provides_written_statement do
      teaching_authority_provides_written_statement { true }
    end

    trait :with_written_statement do
      needs_written_statement { true }

      after(:create) do |application_form, _evaluator|
        if application_form.teaching_authority_provides_written_statement
          application_form.update!(written_statement_confirmation: true)
        else
          create(:upload, document: application_form.written_statement_document)
        end
      end
    end

    trait :with_reviewer do
      association :reviewer, factory: :staff
    end
  end
end
