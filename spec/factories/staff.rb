# == Schema Information
#
# Table name: staff
#
#  id                             :bigint           not null, primary key
#  assess_permission              :boolean          default(FALSE)
#  azure_ad_uid                   :string
#  change_email_permission        :boolean          default(FALSE), not null
#  change_name_permission         :boolean          default(FALSE), not null
#  change_work_history_permission :boolean          default(FALSE), not null
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
#  name                           :text             default(""), not null
#  remember_created_at            :datetime
#  reset_password_sent_at         :datetime
#  reset_password_token           :string
#  reverse_decision_permission    :boolean          default(FALSE), not null
#  sign_in_count                  :integer          default(0), not null
#  support_console_permission     :boolean          default(FALSE), not null
#  unconfirmed_email              :string
#  unlock_token                   :string
#  verify_permission              :boolean          default(FALSE), not null
#  withdraw_permission            :boolean          default(FALSE), not null
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
    email { Faker::Internet.email }
    password { "example123" }
    name { Faker::Name.name }
    confirmed_at { Time.zone.now }

    trait :with_assess_permission do
      assess_permission { true }
    end

    trait :with_change_email_permission do
      change_email_permission { true }
    end

    trait :with_change_name_permission do
      change_name_permission { true }
    end

    trait :with_change_work_history_permission do
      change_work_history_permission { true }
    end

    trait :with_reverse_decision_permission do
      reverse_decision_permission { true }
    end

    trait :with_support_console_permission do
      support_console_permission { true }
    end

    trait :with_verify_permission do
      verify_permission { true }
    end

    trait :with_withdraw_permission do
      withdraw_permission { true }
    end
  end
end
