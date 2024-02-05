# == Schema Information
#
# Table name: documents
#
#  id                :bigint           not null, primary key
#  available         :boolean
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
FactoryBot.define do
  factory :document do
    association :documentable, factory: :application_form
    sequence :document_type, Document::UNTRANSLATABLE_TYPES.cycle
    completed { false }

    trait :completed do
      completed { true }
    end

    trait :translatable do
      sequence :document_type, Document::TRANSLATABLE_TYPES.cycle
    end

    trait :with_upload do
      completed
      after(:create) do |document, _evaluator|
        create(:upload, :clean, document:)
      end
    end

    trait :with_translation do
      completed
      after(:create) do |document, _evaluator|
        create(:upload, :translation, :clean, document:)
      end
    end

    trait :identification do
      document_type { "identification" }
      association :documentable, factory: :application_form
    end

    trait :qualification_certificate do
      document_type { "qualification_certificate" }
      association :documentable, factory: :qualification
    end

    trait :qualification_document do
      document_type { "qualification_document" }
      association :documentable, factory: :further_information_request_item
    end

    trait :qualification_transcript do
      document_type { "qualification_transcript" }
      association :documentable, factory: :qualification
    end

    trait :name_change do
      document_type { "name_change" }
      association :documentable, factory: :application_form
    end

    trait :optional_written_statement do
      written_statement
      after(:create) do |document, _evaluator|
        document.application_form.update!(written_statement_optional: true)
      end
    end

    trait :signed_consent do
      document_type { "signed_consent" }
      association :documentable, factory: :qualification_request
    end

    trait :unsigned_consent do
      document_type { "unsigned_consent" }
      association :documentable, factory: :qualification_request
    end

    trait :written_statement do
      document_type { "written_statement" }
      association :documentable, factory: :application_form
    end
  end
end
