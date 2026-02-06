# frozen_string_literal: true

# == Schema Information
#
# Table name: support_requests
#
#  id                        :bigint           not null, primary key
#  application_enquiry_type  :string
#  application_reference     :string
#  comment                   :text
#  email                     :string
#  name                      :string
#  submitted_at              :datetime
#  user_type                 :string
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

    user_type { "other" }

    trait :application_submitted_user do
      user_type { "application_submitted" }

      application_reference { "000001" }
      application_enquiry_type { "other" }
    end

    trait :submitting_an_application_user do
      user_type { "submitting_an_application" }
    end

    trait :providing_a_reference_user do
      user_type { "providing_a_reference" }
    end
  end
end
