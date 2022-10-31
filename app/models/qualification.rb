# == Schema Information
#
# Table name: qualifications
#
#  id                        :bigint           not null, primary key
#  certificate_date          :date
#  complete_date             :date
#  institution_country_code  :text             default(""), not null
#  institution_name          :text             default(""), not null
#  part_of_university_degree :boolean
#  start_date                :date
#  title                     :text             default(""), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  application_form_id       :bigint           not null
#
# Indexes
#
#  index_qualifications_on_application_form_id  (application_form_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
class Qualification < ApplicationRecord
  include ApplicationFormStatusUpdatable

  belongs_to :application_form
  has_many :documents, as: :documentable

  scope :ordered, -> { order(created_at: :asc) }

  before_create :build_documents

  def is_teaching_qualification?
    application_form.qualifications.empty? ||
      application_form.qualifications.min_by(&:created_at) == self
  end

  def is_university_degree?
    !is_teaching_qualification?
  end

  def locale_key
    is_teaching_qualification? ? "teaching_qualification" : "university_degree"
  end

  def can_delete?
    return false if is_teaching_qualification?

    part_of_university_degree =
      application_form.teaching_qualification&.part_of_university_degree
    return true if part_of_university_degree.nil? || part_of_university_degree

    application_form.qualifications.count > 2
  end

  def institution_country_name
    CountryName.from_code(institution_country_code)
  end

  def institution_country_location
    CountryCode.to_location(institution_country_code)
  end

  def certificate_document
    documents.find(&:qualification_certificate?)
  end

  def transcript_document
    documents.find(&:qualification_transcript?)
  end

  private

  def build_documents
    documents.build(document_type: :qualification_certificate)
    documents.build(document_type: :qualification_transcript)
  end
end
