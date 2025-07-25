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
#  has_other_england_work_history                :boolean
#  has_work_history                              :boolean
#  identification_document_status                :string           default("not_started"), not null
#  includes_prioritisation_features              :boolean          default(FALSE), not null
#  needs_registration_number                     :boolean          not null
#  needs_work_history                            :boolean          not null
#  needs_written_statement                       :boolean          not null
#  other_england_work_history_status             :string           default("not_started"), not null
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
class ApplicationForm < ApplicationRecord
  ATTACHABLE_DOCUMENT_TYPES = %w[
    passport
    identification
    name_change
    medium_of_instruction
    english_for_speakers_of_other_languages
    english_language_proficiency
    written_statement
  ].freeze

  include Documentable
  include Expirable
  include Remindable

  belongs_to :teacher
  belongs_to :region
  belongs_to :english_language_provider, optional: true
  has_many :work_histories, dependent: :destroy
  has_many :qualifications, dependent: :destroy
  has_many :timeline_events
  has_one :country, through: :region
  has_one :trs_trn_request
  has_one :assessment
  has_many :notes, dependent: :destroy

  validates :reference, presence: true, uniqueness: true, length: 3..31

  belongs_to :assessor, class_name: "Staff", optional: true
  belongs_to :reviewer, class_name: "Staff", optional: true

  validates :awarded_at, absence: true, if: :declined_at?
  validates :awarded_at, absence: true, if: :withdrawn_at?
  validates :declined_at, absence: true, if: :awarded_at?
  validates :declined_at, absence: true, if: :withdrawn_at?
  validates :withdrawn_at, absence: true, if: :awarded_at?
  validates :withdrawn_at, absence: true, if: :declined_at?

  enum :english_language_proof_method,
       {
         medium_of_instruction: "medium_of_instruction",
         provider: "provider",
         esol: "esol",
       },
       prefix: true

  validates :english_language_provider,
            absence: true,
            if: :english_language_provider_other

  enum :action_required_by,
       {
         admin: "admin",
         assessor: "assessor",
         external: "external",
         none: "none",
       },
       prefix: true

  enum :stage,
       {
         draft: "draft",
         pre_assessment: "pre_assessment",
         not_started: "not_started",
         assessment: "assessment",
         verification: "verification",
         review: "review",
         completed: "completed",
       },
       suffix: true

  STATUS_COLUMNS = %i[
    personal_information_status
    identification_document_status
    passport_document_status
    qualifications_status
    age_range_status
    subjects_status
    english_language_status
    work_history_status
    other_england_work_history_status
    registration_number_status
    written_statement_status
  ].freeze

  STATUS_VALUES = {
    completed: "completed",
    error: "error",
    in_progress: "in_progress",
    not_started: "not_started",
  }.freeze

  STATUS_COLUMNS.each { |column| enum column, STATUS_VALUES, prefix: column }

  scope :assessable, -> { where.not(stage: %i[draft completed]) }

  scope :submitted, -> { where.not(stage: "draft") }

  scope :destroyable,
        -> do
          where(submitted_at: nil)
            .where("created_at < ?", 6.months.ago)
            .or(where("awarded_at < ?", 5.years.ago))
            .or(where("declined_at < ?", 5.years.ago))
            .or(where("withdrawn_at < ?", 5.years.ago))
        end

  scope :remindable,
        -> do
          joins(region: :country)
            .verification_stage
            .or(
              where(
                countries: {
                  eligibility_enabled: true,
                },
                created_at: ...5.months.ago,
                submitted_at: nil,
              ),
            )
            .or(
              pre_assessment_stage.where(
                includes_prioritisation_features: true,
              ),
            )
        end

  scope :from_ineligible_country,
        -> do
          joins(region: :country).where(
            countries: {
              eligibility_enabled: false,
            },
          )
        end

  def submitted?
    submitted_at.present?
  end

  def awarded?
    awarded_at.present?
  end

  def declined?
    declined_at.present?
  end

  def withdrawn?
    withdrawn_at.present?
  end

  def to_param
    reference
  end

  def teaching_qualification
    qualifications.find(&:is_teaching?)
  end

  def bachelor_degree_qualification
    qualifications.find(&:is_bachelor_degree?)
  end

  def identification_document
    documents.find(&:identification?)
  end

  def passport_document
    documents.find(&:passport?)
  end

  def name_change_document
    documents.find(&:name_change?)
  end

  def english_language_medium_of_instruction_document
    documents.find(&:medium_of_instruction?)
  end

  def english_language_proficiency_document
    documents.find(&:english_language_proficiency?)
  end

  def written_statement_document
    documents.find(&:written_statement?)
  end

  def english_language_exempt?
    english_language_citizenship_exempt || english_language_qualification_exempt
  end

  def created_under_old_regulations?
    created_at < Date.new(2023, 2, 1)
  end

  def submitted_under_old_criteria?
    created_under_old_regulations? || subject_limited != country.subject_limited
  end

  def reminder_email_names
    %w[consent expiration references prioritisation_references]
  end

  def should_send_reminder_email?(name, number_of_reminders_sent)
    return false if teacher.application_form != self

    case name
    when "consent"
      number_of_reminders_sent.zero? &&
        consent_requests_not_yet_received_or_rejected.any? do |consent_request|
          consent_request.days_until_expired <= 21
        end
    when "expiration"
      return false if days_until_expired.nil?

      (days_until_expired <= 14 && number_of_reminders_sent.zero?) ||
        (days_until_expired <= 7 && number_of_reminders_sent == 1)
    when "references"
      reference_requests_not_yet_received_or_rejected.any? do |reference_request|
        reference_request.should_send_reminder_email?(
          "expiration",
          number_of_reminders_sent,
        )
      end
    when "prioritisation_references"
      prioritisation_reference_requests_not_yet_received_or_rejected.any? do |prioritisation_reference_request|
        prioritisation_reference_request.should_send_reminder_email?(
          "expiration",
          number_of_reminders_sent,
        )
      end
    end
  end

  def send_reminder_email(name, number_of_reminders_sent)
    case name
    when "consent"
      DeliverEmail.call(
        application_form: self,
        mailer: TeacherMailer,
        action: :consent_reminder,
      )
    when "expiration"
      DeliverEmail.call(
        application_form: self,
        mailer: TeacherMailer,
        action: :application_not_submitted,
        number_of_reminders_sent:,
      )
    when "references"
      DeliverEmail.call(
        application_form: self,
        mailer: TeacherMailer,
        action: :references_reminder,
        number_of_reminders_sent:,
        reference_requests:
          reference_requests_not_yet_received_or_rejected.to_a,
      )
    when "prioritisation_references"
      DeliverEmail.call(
        application_form: self,
        mailer: TeacherMailer,
        action: :prioritisation_references_reminder,
        number_of_reminders_sent:,
        prioritisation_reference_requests:
          prioritisation_reference_requests_not_yet_received_or_rejected.to_a,
      )
    end
  end

  def requested_at
    created_at
  end

  def received_at
    submitted_at
  end

  def expires_after
    submitted? ? nil : 6.months
  end

  def passport_country_of_issue_name
    CountryOfIssueForPassport.to_name(passport_country_of_issue_code)
  end

  private

  def reference_requests_not_yet_received_or_rejected
    ReferenceRequest
      .joins(:work_history)
      .where(work_histories: { application_form_id: id })
      .where.not(requested_at: nil)
      .where(received_at: nil, verify_passed: nil, review_passed: nil)
  end

  def prioritisation_reference_requests_not_yet_received_or_rejected
    PrioritisationReferenceRequest
      .joins(:work_history)
      .where(work_histories: { application_form_id: id })
      .where.not(requested_at: nil)
      .where(received_at: nil, review_passed: nil)
  end

  def consent_requests_not_yet_received_or_rejected
    ConsentRequest
      .joins(:qualification)
      .where(qualifications: { application_form_id: id })
      .where.not(requested_at: nil)
      .where(received_at: nil, verify_passed: nil)
  end
end
