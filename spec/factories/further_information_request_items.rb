#frozen_string_literal: true

# == Schema Information
#
# Table name: further_information_request_items
#
#  id                               :bigint           not null, primary key
#  contact_email                    :string
#  contact_job                      :string
#  contact_name                     :string
#  failure_reason_assessor_feedback :text
#  failure_reason_key               :string           default(""), not null
#  information_type                 :string
#  response                         :text
#  review_decision                  :string
#  review_decision_note             :text
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  further_information_request_id   :bigint
#  work_history_id                  :bigint
#
# Indexes
#
#  index_fi_request_items_on_fi_request_id                     (further_information_request_id)
#  index_further_information_request_items_on_work_history_id  (work_history_id)
#
# Foreign Keys
#
#  fk_rails_...  (work_history_id => work_histories.id)
#
FactoryBot.define do
  factory :further_information_request_item do
    further_information_request

    failure_reason_assessor_feedback { Faker::Lorem.paragraph }

    trait :with_text_response do
      information_type { "text" }
      failure_reason_key { "qualifications_dont_match_subjects" }
    end

    trait :with_document_response do
      information_type { "document" }
      failure_reason_key { "identification_document_illegible" }

      after(:create) do |item|
        create(:document, :identification, documentable: item)
      end
    end

    trait :with_passport_document_response do
      information_type { "document" }
      failure_reason_key { "passport_document_illegible" }

      after(:create) { |item| create(:document, :passport, documentable: item) }
    end

    trait :with_work_history_contact_response do
      information_type { "work_history_contact" }
      failure_reason_key { "unrecognised_references" }
      work_history do
        further_information_request.application_form.work_histories.first
      end
    end

    trait :completed do
      response { Faker::Lorem.paragraph if text? }

      after(:create) do |item, _evaluator|
        create(:upload, document: item.document) if item.document?
      end
    end
  end
end
