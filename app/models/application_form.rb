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
#  reference               :string(31)       not null
#  status                  :string           default("active"), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  eligibility_check_id    :bigint           not null
#  teacher_id              :bigint           not null
#
# Indexes
#
#  index_application_forms_on_eligibility_check_id  (eligibility_check_id)
#  index_application_forms_on_reference             (reference) UNIQUE
#  index_application_forms_on_status                (status)
#  index_application_forms_on_teacher_id            (teacher_id)
#
# Foreign Keys
#
#  fk_rails_...  (eligibility_check_id => eligibility_checks.id)
#  fk_rails_...  (teacher_id => teachers.id)
#
class ApplicationForm < ApplicationRecord
  include DfE::Analytics::Entities

  belongs_to :teacher
  belongs_to :eligibility_check
  has_many :work_histories
  has_one :region, through: :eligibility_check

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

  validates :reference, presence: true, uniqueness: true, length: 3..31

  enum status: { active: "active", submitted: "submitted" }

  before_validation :assign_reference, on: :create

  def assign_reference
    return if reference
    ActiveRecord::Base.connection.execute(
      "LOCK TABLE application_forms IN EXCLUSIVE MODE"
    )
    self.reference = (ApplicationForm.maximum(:reference) || "2000000").to_i + 1
  end

  def tasks
    @tasks ||=
      begin
        hash = {}
        hash.merge!(about_you: %i[personal_information])
        hash.merge!(qualifications: %i[age_range])
        hash.merge!(work_history: %i[work_history]) if needs_work_history?
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

  def task_item_started?(section, item)
    task_statuses.dig(section, item) != :not_started
  end

  def can_submit?
    completed_task_sections.count == tasks.count
  end

  def path_for_task_item(key)
    url_helpers = Rails.application.routes.url_helpers

    key = :work_histories if key == :work_history

    begin
      url_helpers.send("teacher_interface_application_form_#{key}_path", self)
    rescue NoMethodError
      url_helpers.send("#{key}_teacher_interface_application_form_path", self)
    end
  end

  private

  def build_documents
    build_identification_document(document_type: :identification)
    build_name_change_document(document_type: :name_change)
    build_written_statement_document(document_type: :written_statement)
  end

  def needs_work_history?
    region.status_check_none? || region.sanction_check_none?
  end

  def task_item_status(key)
    case key
    when :personal_information
      personal_information_status
    when :age_range
      status_for_values(age_range_min, age_range_max)
    when :work_history
      return :not_started if work_histories.empty?
      if work_histories.completed.count == work_histories.count
        return :completed
      end
      :in_progress
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

  def status_for_values(*values)
    return :not_started if values.all?(&:blank?)
    return :completed if values.all?(&:present?)
    :in_progress
  end
end
