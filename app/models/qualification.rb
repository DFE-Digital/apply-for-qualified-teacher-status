# == Schema Information
#
# Table name: qualifications
#
#  id                  :bigint           not null, primary key
#  certificate_date    :date
#  complete_date       :date
#  institution_country :text             default(""), not null
#  institution_name    :text             default(""), not null
#  start_date          :date
#  title               :text             default(""), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint           not null
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
  belongs_to :application_form

  has_one :certificate_document,
          -> { where(document_type: :qualification_certificate) },
          class_name: "Document",
          as: :documentable

  has_one :transcript_document,
          -> { where(document_type: :qualification_transcript) },
          class_name: "Document",
          as: :documentable

  scope :completed,
        -> {
          where
            .not(title: "", institution_name: "", institution_country: "")
            .where.not(
              start_date: nil,
              complete_date: nil,
              certificate_date: nil
            )
        }

  scope :ordered, -> { order(created_at: :asc) }

  validates :start_date,
            comparison: {
              allow_nil: true,
              less_than: :complete_date
            },
            if: -> { complete_date.present? }
  validates :complete_date,
            comparison: {
              allow_nil: true,
              greater_than: :start_date
            },
            if: -> { start_date.present? }

  before_create :build_documents

  def status
    values = [
      title,
      institution_name,
      institution_country,
      start_date,
      complete_date,
      certificate_date,
      certificate_document.uploaded?,
      transcript_document.uploaded?
    ]

    return :not_started if values.all?(&:blank?)
    return :completed if values.all?(&:present?)
    :in_progress
  end

  def is_teaching_qualification?
    (new_record? && application_form.qualifications.empty?) ||
      application_form.qualifications.ordered.first == self
  end

  def is_university_degree?
    !is_teaching_qualification?
  end

  def locale_key
    is_teaching_qualification? ? "teaching_qualification" : "university_degree"
  end

  private

  def build_documents
    build_certificate_document(document_type: :qualification_certificate)
    build_transcript_document(document_type: :qualification_transcript)
  end
end
