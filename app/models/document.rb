# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  id                :bigint           not null, primary key
#  available         :boolean
#  document_type     :string           not null
#  documentable_type :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  documentable_id   :bigint
#
# Indexes
#
#  index_documents_on_document_type  (document_type)
#  index_documents_on_documentable   (documentable_type,documentable_id)
#

class Document < ApplicationRecord
  belongs_to :documentable, polymorphic: true

  has_many :uploads, dependent: :destroy

  has_many :original_uploads,
           -> { where(translation: false) },
           class_name: "Upload"

  has_many :translated_uploads,
           -> { where(translation: true) },
           class_name: "Upload"

  UNTRANSLATABLE_TYPES = %w[
    english_language_proficiency
    identification
    medium_of_instruction
    name_change
    passport
  ].freeze

  UNTRANSLATABLE_SINGLE_TYPES = %w[signed_consent unsigned_consent].freeze

  TRANSLATABLE_TYPES = %w[
    qualification_certificate
    qualification_document
    qualification_transcript
    written_statement
  ].freeze

  DOCUMENT_TYPES =
    (
      UNTRANSLATABLE_TYPES + UNTRANSLATABLE_SINGLE_TYPES + TRANSLATABLE_TYPES
    ).freeze

  enum :document_type,
       DOCUMENT_TYPES.each_with_object({}) { |type, memo| memo[type] = type }
  validates :document_type, inclusion: { in: DOCUMENT_TYPES }

  def translatable?
    TRANSLATABLE_TYPES.include?(document_type)
  end

  def allow_multiple_uploads?
    !UNTRANSLATABLE_SINGLE_TYPES.include?(document_type)
  end

  def optional?
    written_statement? && application_form.written_statement_optional
  end

  def completed?
    (uploads.present? && uploads.all?(&:safe_to_link?)) ||
      (optional? && available == false)
  end

  def any_unsafe_to_link?
    uploads.any?(&:unsafe_to_link?)
  end

  def empty?
    uploads.empty? && available.nil?
  end

  def status
    if any_unsafe_to_link?
      "error"
    elsif completed?
      "completed"
    elsif empty?
      "not_started"
    else
      "in_progress"
    end
  end

  def for_further_information_request?
    documentable.is_a?(FurtherInformationRequestItem)
  end

  def for_consent_request?
    documentable.is_a?(ConsentRequest)
  end

  def application_form
    @application_form ||=
      if documentable.is_a?(ApplicationForm)
        documentable
      else
        documentable.try(:application_form)
      end
  end
end
