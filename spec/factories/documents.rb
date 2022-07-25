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
FactoryBot.define do
  factory :document do
    association :documentable, factory: :application_form
    sequence :type, Document::UNTRANSLATABLE_TYPES.cycle

    trait :translatable do
      sequence :type, Document::TRANSLATABLE_TYPES.cycle
    end
  end
end
