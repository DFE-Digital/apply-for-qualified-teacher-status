# == Schema Information
#
# Table name: uploads
#
#  id          :bigint           not null, primary key
#  translation :boolean          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  document_id :bigint           not null
#
# Indexes
#
#  index_uploads_on_document_id  (document_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id)
#
FactoryBot.define do
  factory :upload do
    association :document
    translation { false }

    trait :translation do
      translation { true }
    end
  end
end
