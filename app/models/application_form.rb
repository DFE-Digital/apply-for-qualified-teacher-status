# == Schema Information
#
# Table name: application_forms
#
#  id                      :bigint           not null, primary key
#  age_range_max           :integer
#  age_range_min           :integer
#  alternative_family_name :text             default(""), not null
#  alternative_given_names :text             default(""), not null
#  date_of_birth           :date
#  family_name             :text             default(""), not null
#  given_names             :text             default(""), not null
#  has_alternative_name    :boolean
#  has_work_history        :boolean
#  reference               :string(31)       not null
#  registration_number     :text
#  state                   :string           default("draft"), not null
#  subjects                :text             default([]), not null, is an Array
#  submitted_at            :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  assessor_id             :bigint
#  region_id               :bigint           not null
#  reviewer_id             :bigint
#  teacher_id              :bigint           not null
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
  has_many :work_histories
  has_many :qualifications
  has_many :documents, as: :documentable
  has_many :timeline_events

  before_create :build_documents

  before_validation :assign_reference
  validates :reference, presence: true, uniqueness: true, length: 3..31

  belongs_to :assessor, class_name: "Staff", optional: true
  belongs_to :reviewer, class_name: "Staff", optional: true
  validate :assessor_and_reviewer_must_be_different

  validates :submitted_at, presence: true, unless: :draft?

  enum state: {
         draft: "draft",
         submitted: "submitted",
         awarded: "awarded",
         declined: "declined"
       }

  scope :active, -> { not_draft }

  def assign_reference
    return if reference.present?

    ActiveRecord::Base.connection.execute(
      "LOCK TABLE application_forms IN EXCLUSIVE MODE"
    )

    max_reference = ApplicationForm.maximum(:reference)&.to_i
    max_reference = 2_000_000 if max_reference.nil? || max_reference.zero?

    self.reference = (max_reference + 1).to_s.rjust(7, "0")
  end

  def tasks
    @tasks ||=
      begin
        hash = {}
        hash.merge!(about_you: %i[personal_information identity_document])
        hash.merge!(qualifications: %i[qualifications age_range subjects])
        hash.merge!(work_history: %i[work_history]) if needs_work_history?

        if needs_written_statement? || needs_registration_number?
          hash.merge!(
            proof_of_recognition: [
              needs_registration_number? ? :registration_number : nil,
              needs_written_statement? ? :written_statement : nil
            ].compact
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
      .filter { |_, statuses| statuses.values.all?(:completed) }
      .map { |section, _| section }
  end

  def task_item_completed?(section, item)
    task_statuses.dig(section, item) == :completed
  end

  def can_submit?
    completed_task_sections.count == tasks.count
  end

  def path_for_task_item(key)
    url_helpers = Rails.application.routes.url_helpers

    if key == :identity_document
      return(
        url_helpers.edit_teacher_interface_application_form_document_path(
          identification_document
        )
      )
    end

    if key == :written_statement
      return(
        url_helpers.edit_teacher_interface_application_form_document_path(
          written_statement_document
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

  def needs_work_history?
    region.status_check_none? || region.sanction_check_none?
  end

  def needs_registration_number?
    region.status_check_online? || region.sanction_check_online?
  end

  def needs_written_statement?
    region.status_check_written? || region.sanction_check_written?
  end

  def teaching_qualification
    qualifications.find(&:is_teaching_qualification?)
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
    case key
    when :personal_information
      personal_information_status
    when :identity_document
      identification_document.uploaded? ? :completed : :not_started
    when :qualifications
      qualifications_status
    when :age_range
      status_for_values(age_range_min, age_range_max)
    when :subjects
      subjects_status
    when :work_history
      work_history_status
    when :registration_number
      registration_number.nil? ? :not_started : :completed
    when :written_statement
      written_statement_document.uploaded? ? :completed : :not_started
    else
      :not_started
    end
  end

  def personal_information_status
    values = [given_names, family_name, date_of_birth]

    if has_alternative_name.nil?
      values.append(nil)
    elsif has_alternative_name
      values.append(
        alternative_given_names,
        alternative_family_name,
        name_change_document&.uploaded?
      )
    else
      values.append(true)
    end

    status_for_values(*values)
  end

  def qualifications_status
    return :not_started if qualifications.empty?

    part_of_university_degree = teaching_qualification.part_of_university_degree
    if part_of_university_degree.nil? ||
         (!part_of_university_degree && qualifications.count == 1)
      return :in_progress
    end

    all_complete =
      qualifications.all? { |qualification| qualification.status == :completed }

    all_complete ? :completed : :in_progress
  end

  def subjects_status
    return :not_started if subjects.empty?
    return :in_progress if subjects.compact_blank.empty?
    :completed
  end

  def work_history_status
    return :not_started if has_work_history.nil?

    if !has_work_history ||
         (
           !work_histories.empty? &&
             work_histories.all? do |work_history|
               work_history.status == :completed
             end
         )
      return :completed
    end

    :in_progress
  end

  def status_for_values(*values)
    return :not_started if values.all?(&:blank?)
    return :completed if values.all?(&:present?)
    :in_progress
  end
end
