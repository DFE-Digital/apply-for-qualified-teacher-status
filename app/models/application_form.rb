# == Schema Information
#
# Table name: application_forms
#
#  id                             :bigint           not null, primary key
#  age_range_max                  :integer
#  age_range_min                  :integer
#  age_range_status               :string           default("not_started"), not null
#  alternative_family_name        :text             default(""), not null
#  alternative_given_names        :text             default(""), not null
#  confirmed_no_sanctions         :boolean          default(FALSE)
#  date_of_birth                  :date
#  family_name                    :text             default(""), not null
#  given_names                    :text             default(""), not null
#  has_alternative_name           :boolean
#  has_work_history               :boolean
#  identification_document_status :string           default("not_started"), not null
#  needs_registration_number      :boolean          not null
#  needs_work_history             :boolean          not null
#  needs_written_statement        :boolean          not null
#  personal_information_status    :string           default("not_started"), not null
#  qualifications_status          :string           default("not_started"), not null
#  reference                      :string(31)       not null
#  registration_number            :text
#  registration_number_status     :string           default("not_started"), not null
#  state                          :string           default("draft"), not null
#  subjects                       :text             default([]), not null, is an Array
#  subjects_status                :string           default("not_started"), not null
#  submitted_at                   :datetime
#  work_history_status            :string           default("not_started"), not null
#  working_days_since_submission  :integer
#  written_statement_status       :string           default("not_started"), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  assessor_id                    :bigint
#  region_id                      :bigint           not null
#  reviewer_id                    :bigint
#  teacher_id                     :bigint           not null
#
# Indexes
#
#  index_application_forms_on_assessor_id  (assessor_id)
#  index_application_forms_on_family_name  (family_name)
#  index_application_forms_on_given_names  (given_names)
#  index_application_forms_on_reference    (reference) UNIQUE
#  index_application_forms_on_region_id    (region_id)
#  index_application_forms_on_reviewer_id  (reviewer_id)
#  index_application_forms_on_state        (state)
#  index_application_forms_on_teacher_id   (teacher_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessor_id => staff.id)
#  fk_rails_...  (region_id => regions.id)
#  fk_rails_...  (reviewer_id => staff.id)
#  fk_rails_...  (teacher_id => teachers.id)
#
class ApplicationForm < ApplicationRecord
  belongs_to :teacher
  belongs_to :region
  has_many :work_histories, dependent: :destroy
  has_many :qualifications, dependent: :destroy
  has_many :documents, as: :documentable, dependent: :destroy
  has_many :timeline_events
  has_one :dqt_trn_request
  has_one :assessment
  has_many :notes, dependent: :destroy

  before_save :build_documents, if: :new_record?

  before_validation :assign_reference
  validates :reference, presence: true, uniqueness: true, length: 3..31

  belongs_to :assessor, class_name: "Staff", optional: true
  belongs_to :reviewer, class_name: "Staff", optional: true
  validate :assessor_and_reviewer_must_be_different

  validates :submitted_at, presence: true, unless: :draft?

  enum state: {
         draft: "draft",
         submitted: "submitted",
         initial_assessment: "initial_assessment",
         further_information_requested: "further_information_requested",
         further_information_received: "further_information_received",
         awarded_pending_checks: "awarded_pending_checks",
         awarded: "awarded",
         declined: "declined",
         potential_duplicate_in_dqt: "potential_duplicate_in_dqt",
       }

  delegate :country, to: :region, allow_nil: true

  STATUS_COLUMNS = %i[
    personal_information_status
    identification_document_status
    qualifications_status
    age_range_status
    subjects_status
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

  scope :active, -> { not_draft }

  def assign_reference
    return if reference.present?

    ActiveRecord::Base.connection.execute(
      "LOCK TABLE application_forms IN EXCLUSIVE MODE",
    )

    max_reference = ApplicationForm.maximum(:reference)&.to_i
    max_reference = 2_000_000 if max_reference.nil? || max_reference.zero?

    self.reference = (max_reference + 1).to_s.rjust(7, "0")
  end

  def tasks
    @tasks ||=
      begin
        hash = {}
        hash.merge!(about_you: %i[personal_information identification_document])
        hash.merge!(qualifications: %i[qualifications age_range subjects])
        hash.merge!(work_history: %i[work_history]) if needs_work_history

        if needs_written_statement || needs_registration_number
          hash.merge!(
            proof_of_recognition: [
              needs_registration_number ? :registration_number : nil,
              needs_written_statement ? :written_statement : nil,
            ].compact,
          )
        end

        hash
      end
  end

  def task_statuses
    @task_statuses ||=
      tasks.transform_values do |items|
        items.index_with { |item| task_item_status(item) }
      end
  end

  def completed_task_sections
    task_statuses
      .filter { |_, statuses| statuses.values.all?("completed") }
      .map { |section, _| section }
  end

  def task_item_completed?(section, item)
    task_statuses.dig(section, item) == "completed"
  end

  def can_submit?
    completed_task_sections.count == tasks.count
  end

  def path_for_task_item(key)
    url_helpers = Rails.application.routes.url_helpers

    if key == :identification_document
      return(
        url_helpers.teacher_interface_application_form_document_path(
          identification_document,
        )
      )
    end

    if key == :written_statement
      return(
        url_helpers.teacher_interface_application_form_document_path(
          written_statement_document,
        )
      )
    end

    key = :work_histories if key == :work_history

    begin
      url_helpers.send("teacher_interface_application_form_#{key}_path")
    rescue NoMethodError
      url_helpers.send("#{key}_teacher_interface_application_form_path")
    end
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

  def written_statement_document
    documents.find(&:written_statement?)
  end

  private

  def build_documents
    documents.build(document_type: :identification)
    documents.build(document_type: :name_change)
    documents.build(document_type: :written_statement)
  end

  def assessor_and_reviewer_must_be_different
    if assessor_id.present? && reviewer_id.present? &&
         assessor_id == reviewer_id
      errors.add(:reviewer, :same_as_assessor)
    end
  end

  def task_item_status(key)
    send("#{key}_status")
  end
end
