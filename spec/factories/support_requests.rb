# frozen_string_literal: true

# == Schema Information
#
# Table name: support_requests
#
#  id                        :bigint           not null, primary key
#  application_enquiry_type  :string
#  application_reference     :string
#  category_type             :string
#  comment                   :text
#  email                     :string
#  name                      :string
#  submitted_at              :datetime
#  zendesk_ticket_created_at :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  zendesk_ticket_id         :string
#
FactoryBot.define do
  factory :support_request do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    comment { Faker::Lorem.sentence }

    category_type { "other" }

    trait :application_submitted_category do
      category_type { "application_submitted" }

      application_reference { "000001" }
      application_enquiry_type { "other" }
    end

    trait :submitting_an_application_category do
      category_type { "submitting_an_application" }
    end

    trait :providing_a_reference_category do
      category_type { "providing_a_reference" }
    end
  end
end
