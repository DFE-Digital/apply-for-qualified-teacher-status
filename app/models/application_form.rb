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
#  status                  :string           default("active"), not null
#  subjects                :text             default([]), not null, is an Array
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  region_id               :bigint           not null
#  teacher_id              :bigint           not null
#
# Indexes
#
#  index_application_forms_on_reference   (reference) UNIQUE
#  index_application_forms_on_region_id   (region_id)
#  index_application_forms_on_status      (status)
#  index_application_forms_on_teacher_id  (teacher_id)
#
# Foreign Keys
#
#  fk_rails_...  (region_id => regions.id)
#  fk_rails_...  (teacher_id => teachers.id)
#
class ApplicationForm < ApplicationRecord
  belongs_to :teacher
  belongs_to :region
  has_many :work_histories
  has_many :qualifications

  has_one :identification_document,
          -> { where(document_type: :identification) },
          class_name: "Document",
          as: :documentable

  has_one :name_change_document,
          -> { where(document_type: :name_change) },
          class_name: "Document",
          as: :documentable

  has_one :written_statement_document,
          -> { where(document_type: :written_statement) },
          class_name: "Document",
          as: :documentable

  before_create :build_documents

  before_validation :assign_reference
  validates :reference, presence: true, uniqueness: true, length: 3..31

  enum status: { active: "active", submitted: "submitted" }

  def assign_reference
    return if reference.present? && reference.length >= 3
    ActiveRecord::Base.connection.execute(
      "LOCK TABLE application_forms IN EXCLUSIVE MODE"
    )
    self.reference = (ApplicationForm.maximum(:reference) || "2000000").to_i + 1
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
    qualifications.ordered.first
  end

  private

  def build_documents
    build_identification_document(document_type: :identification)
    build_name_change_document(document_type: :name_change)
    build_written_statement_document(document_type: :written_statement)
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
             work_histories.completed.count == work_histories.count
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
