# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  id                :bigint           not null, primary key
#  completed         :boolean          default(FALSE)
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

  scope :completed, -> { where(completed: true) }
  scope :not_completed, -> { where(completed: false) }

  UNTRANSLATABLE_TYPES = %w[
    identification
    name_change
    medium_of_instruction
    english_language_proficiency
  ].freeze
  TRANSLATABLE_TYPES = %w[
    qualification_certificate
    qualification_transcript
    qualification_document
    written_statement
  ].freeze
  DOCUMENT_TYPES = (UNTRANSLATABLE_TYPES + TRANSLATABLE_TYPES).freeze

  enum document_type:
         DOCUMENT_TYPES.each_with_object({}) { |type, memo| memo[type] = type }
  validates :document_type, inclusion: { in: DOCUMENT_TYPES }

  def translatable?
    TRANSLATABLE_TYPES.include?(document_type)
  end

  def uploaded?
    !uploads.empty?
  end

  def for_further_information_request?
    documentable.is_a?(FurtherInformationRequestItem)
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
