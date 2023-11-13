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
class ApplicationForm < ApplicationRecord
  include Expirable
  include Remindable

  belongs_to :teacher
  belongs_to :region
  belongs_to :english_language_provider, optional: true
  has_many :work_histories, dependent: :destroy
  has_many :qualifications, dependent: :destroy
  has_many :documents, as: :documentable, dependent: :destroy
  has_many :timeline_events
  has_one :dqt_trn_request
  has_one :assessment
  has_many :notes, dependent: :destroy

  before_save :build_documents, if: :new_record?

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
       { medium_of_instruction: "medium_of_instruction", provider: "provider" },
       prefix: true

  validates :english_language_provider,
            absence: true,
            if: :english_language_provider_other

  enum action_required_by: {
         admin: "admin",
         assessor: "assessor",
         external: "external",
         none: "none",
       },
       _prefix: true

  enum stage: {
         draft: "draft",
         pre_assessment: "pre_assessment",
         not_started: "not_started",
         assessment: "assessment",
         verification: "verification",
         review: "review",
         completed: "completed",
       },
       _suffix: true

  enum status: {
         draft: "draft",
         submitted: "submitted",
         preliminary_check: "preliminary_check",
         assessment_in_progress: "assessment_in_progress",
         waiting_on: "waiting_on",
         received: "received",
         overdue: "overdue",
         awarded_pending_checks: "awarded_pending_checks",
         awarded: "awarded",
         declined: "declined",
         potential_duplicate_in_dqt: "potential_duplicate_in_dqt",
         withdrawn: "withdrawn",
       }

  delegate :country, to: :region, allow_nil: true

  STATUS_COLUMNS = %i[
    personal_information_status
    identification_document_status
    qualifications_status
    age_range_status
    subjects_status
    english_language_status
    work_history_status
    registration_number_status
    written_statement_status
  ].freeze

  STATUS_VALUES = {
    not_started: "not_started",
    in_progress: "in_progress",
    completed: "completed",
  }.freeze

  STATUS_COLUMNS.each { |column| enum column, STATUS_VALUES, prefix: column }

  scope :assessable,
        -> do
          where(
            status: %i[
              preliminary_check
              submitted
              assessment_in_progress
              waiting_on
              received
              overdue
            ],
          )
        end

  scope :active,
        -> do
          joins(region: :country)
            .where.not(countries: { code: "ZW" })
            .merge(
              assessable
                .or(awarded_pending_checks)
                .or(potential_duplicate_in_dqt)
                .or(awarded.where("awarded_at >= ?", 90.days.ago))
                .or(declined.where("declined_at >= ?", 90.days.ago))
                .or(withdrawn.where("withdrawn_at >= ?", 90.days.ago)),
            )
        end

  scope :destroyable,
        -> do
          draft
            .where("created_at < ?", 6.months.ago)
            .or(awarded.where("awarded_at < ?", 5.years.ago))
            .or(declined.where("declined_at < ?", 5.years.ago))
            .or(withdrawn.where("withdrawn_at < ?", 5.years.ago))
        end

  scope :remindable, -> { draft.where("created_at < ?", 5.months.ago) }

  def to_param
    reference
  end

  def teaching_qualification
    qualifications.find(&:is_teaching_qualification?)
  end

  def degree_qualifications
    qualifications.select(&:is_university_degree?)
  end

  def identification_document
    documents.find(&:identification?)
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

  def created_under_new_regulations?
    created_at >= Date.parse(ENV.fetch("NEW_REGS_DATE", "2023-02-01"))
  end

  def should_send_reminder_email?(number_of_reminders_sent)
    return false if days_until_expired.nil? || teacher.application_form != self

    (days_until_expired <= 14 && number_of_reminders_sent.zero?) ||
      (days_until_expired <= 7 && number_of_reminders_sent == 1)
  end

  def send_reminder_email(number_of_reminders_sent)
    TeacherMailer
      .with(teacher:, number_of_reminders_sent:)
      .application_not_submitted
      .deliver_later
  end

  def expires_after
    draft? ? 6.months : nil
  end

  def requested_at
    created_at
  end

  private

  def build_documents
    documents.build(document_type: :identification)
    documents.build(document_type: :name_change)
    documents.build(document_type: :medium_of_instruction)
    documents.build(document_type: :english_language_proficiency)
    documents.build(document_type: :written_statement)
  end
end
