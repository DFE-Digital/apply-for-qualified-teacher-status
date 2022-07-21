# == Schema Information
#
# Table name: application_forms
#
#  id                   :bigint           not null, primary key
#  date_of_birth        :date
#  family_name          :text             default(""), not null
#  given_names          :text             default(""), not null
#  reference            :string(31)       not null
#  status               :string           default("active"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  eligibility_check_id :bigint           not null
#  teacher_id           :bigint           not null
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

  def sections
    @sections ||=
      begin
        hash = {}
        hash.merge!(about_you: %i[personal_information])
        hash.merge!(your_work_history: %i[work_history]) if needs_work_history?
        hash
      end
  end

  def section_statuses
    @section_statuses ||=
      sections.each_with_object({}) do |(section, subsections), memo|
        memo[section] = subsections.index_with do |subsection|
          subsection_status(section, subsection)
        end
      end
  end

  def completed_sections
    section_statuses
      .filter { |_, statuses| statuses.values.all?(:completed) }
      .map { |section, _| section }
  end

  def can_submit?
    completed_sections.count == sections.count
  end

  def path_for_subsection(key)
    url_helpers = Rails.application.routes.url_helpers

    key = :work_histories if key == :work_history

    begin
      url_helpers.send("teacher_interface_application_form_#{key}_path", self)
    rescue NoMethodError
      url_helpers.send("#{key}_teacher_interface_application_form_path", self)
    end
  end

  def personal_information_status
    values = [given_names, family_name, date_of_birth]
    return :not_started if values.all?(&:blank?)
    return :completed if values.all?(&:present?)
    :in_progress
  end

  private

  def needs_work_history?
    region.status_check_none? || region.sanction_check_none?
  end

  def subsection_status(section, subsection)
    case [section, subsection]
    when %i[about_you personal_information]
      personal_information_status
    when %i[your_work_history work_history]
      return :not_started if work_histories.empty?
      if work_histories.completed.count == work_histories.count
        return :completed
      end
      :in_progress
    else
      :not_started
    end
  end
end
