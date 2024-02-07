# frozen_string_literal: true

module Documentable
  extend ActiveSupport::Concern

  included do |base|
    has_many :documents, as: :documentable, dependent: :destroy

    before_save if: :new_record? do
      base::ATTACHABLE_DOCUMENT_TYPES.each do |document_type|
        documents.build(document_type:)
      end
    end

    base::ATTACHABLE_DOCUMENT_TYPES.each do |document_type|
      define_method "#{document_type}_document" do
        documents.find { |document| document.document_type == document_type }
      end
    end
  end
end
