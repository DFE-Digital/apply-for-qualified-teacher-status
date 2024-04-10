# == Schema Information
#
# Table name: qualifications
#
#  id                       :bigint           not null, primary key
#  certificate_date         :date
#  complete_date            :date
#  institution_country_code :text             default(""), not null
#  institution_name         :text             default(""), not null
#  start_date               :date
#  title                    :text             default(""), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  application_form_id      :bigint           not null
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
  ATTACHABLE_DOCUMENT_TYPES = %w[
    qualification_certificate
    qualification_transcript
  ].freeze

  include Documentable

  belongs_to :application_form

  scope :order_by_role, -> { order(start_date: :desc) }
  scope :order_by_user, -> { order(created_at: :asc) }

  def is_teaching?
    application_form.qualifications.empty? ||
      application_form.qualifications.order(:created_at).first == self
  end

  def is_bachelor_degree?
    if application_form.teaching_qualification_part_of_degree
      is_teaching?
    else
      application_form.qualifications.order(:created_at).second == self
    end
  end

  def locale_key
    if is_teaching?
      "teaching"
    elsif is_bachelor_degree?
      "bachelor_degree"
    else
      "additional"
    end
  end

  def can_delete?
    return false if is_teaching?

    part_of_degree = application_form.teaching_qualification_part_of_degree
    return true if part_of_degree.nil? || part_of_degree

    application_form.qualifications.count > 2
  end

  def complete?
    values = [
      title,
      institution_name,
      institution_country_code,
      start_date,
      complete_date,
      certificate_date,
      certificate_document.completed?,
      transcript_document.completed?,
    ]

    if is_teaching? &&
         application_form.teaching_qualification_part_of_degree != false
      values.push(application_form.teaching_qualification_part_of_degree)
    end

    values.all?(&:present?)
  end

  def incomplete?
    !complete?
  end

  def any_documents_unsafe_to_link?
    certificate_document.any_unsafe_to_link? ||
      transcript_document.any_unsafe_to_link?
  end

  def institution_country_name
    CountryName.from_code(institution_country_code)
  end

  alias_method :certificate_document, :qualification_certificate_document
  alias_method :transcript_document, :qualification_transcript_document
end
