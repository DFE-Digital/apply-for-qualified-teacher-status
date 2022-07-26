# == Schema Information
#
# Table name: documents
#
#  id                :bigint           not null, primary key
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
FactoryBot.define do
  factory :document do
    association :documentable, factory: :application_form
    sequence :document_type, Document::UNTRANSLATABLE_TYPES.cycle

    trait :translatable do
      sequence :document_type, Document::TRANSLATABLE_TYPES.cycle
    end

    trait :with_upload do
      after(:create) { |document, _evaluator| create(:upload, document:) }
    end
  end
end
