# == Schema Information
#
# Table name: documents
#
#  id                :bigint           not null, primary key
#  documentable_type :string
#  type              :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  documentable_id   :bigint
#
# Indexes
#
#  index_documents_on_documentable  (documentable_type,documentable_id)
#  index_documents_on_type          (type)
#
class Document < ApplicationRecord
  include DfE::Analytics::Entities

  belongs_to :documentable, polymorphic: true
  has_many :original_uploads,
           -> { where(translation: false) },
           class_name: "Upload"
  has_many :translated_uploads,
           -> { where(translation: true) },
           class_name: "Upload"

  UNTRANSLATABLE_TYPES = %w[identification name_change].freeze
  TRANSLATABLE_TYPES = %w[
    qualification_certificate
    qualification_transcript
    written_statement
  ].freeze
  TYPES = (UNTRANSLATABLE_TYPES + TRANSLATABLE_TYPES).freeze

  enum type: TYPES.each_with_object({}) { |type, memo| memo[type] = type }
  validates :type, inclusion: { in: TYPES }

  def translatable?
    TRANSLATABLE_TYPES.include?(type)
  end
end
