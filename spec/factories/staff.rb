# == Schema Information
#
# Table name: staff
#
#  id                             :bigint           not null, primary key
#  award_decline_permission       :boolean          default(FALSE)
#  azure_ad_uid                   :string
#  confirmation_sent_at           :datetime
#  confirmation_token             :string
#  confirmed_at                   :datetime
#  current_sign_in_at             :datetime
#  current_sign_in_ip             :string
#  email                          :string           default(""), not null
#  encrypted_password             :string           default(""), not null
#  failed_attempts                :integer          default(0), not null
#  invitation_accepted_at         :datetime
#  invitation_created_at          :datetime
#  invitation_limit               :integer
#  invitation_sent_at             :datetime
#  invitation_token               :string
#  invitations_count              :integer          default(0)
#  invited_by_type                :string
#  last_sign_in_at                :datetime
#  last_sign_in_ip                :string
#  locked_at                      :datetime
#  manage_applications_permission :boolean          default(FALSE), not null
#  name                           :text             default(""), not null
#  remember_created_at            :datetime
#  reset_password_sent_at         :datetime
#  reset_password_token           :string
#  sign_in_count                  :integer          default(0), not null
#  support_console_permission     :boolean          default(FALSE), not null
#  unconfirmed_email              :string
#  unlock_token                   :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  invited_by_id                  :bigint
#
# Indexes
#
#  index_staff_on_confirmation_token    (confirmation_token) UNIQUE
#  index_staff_on_invitation_token      (invitation_token) UNIQUE
#  index_staff_on_invited_by            (invited_by_type,invited_by_id)
#  index_staff_on_invited_by_id         (invited_by_id)
#  index_staff_on_lower_email           (lower((email)::text)) UNIQUE
#  index_staff_on_reset_password_token  (reset_password_token) UNIQUE
#  index_staff_on_unlock_token          (unlock_token) UNIQUE
#
FactoryBot.define do
  factory :staff do
    sequence(:email) { |n| "test#{n}@example.org" }
    password { "example123" }
    name { Faker::Name.name }

    trait :confirmed do
      confirmed_at { Time.zone.now }
    end

    trait :with_manage_applications_permission do
      manage_applications_permission { true }
    end

    trait :with_award_decline_permission do
      award_decline_permission { true }
    end

    trait :with_support_console_permission do
      support_console_permission { true }
    end
  end
end
