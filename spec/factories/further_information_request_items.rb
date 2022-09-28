#frozen_string_literal: true

# == Schema Information
#
# Table name: further_information_request_items
#
#  id                             :bigint           not null, primary key
#  assessor_notes                 :text
#  information_type               :string
#  response                       :text
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  further_information_request_id :bigint
#
# Indexes
#
#  index_fi_request_items_on_fi_request_id  (further_information_request_id)
#
FactoryBot.define do
  factory :further_information_request_item do
    association :further_information_request

    trait :with_text_response do
      information_type { "text" }
    end

    trait :with_document_response do
      information_type { "document" }
      association :document, :further_information_request
    end
  end
end
