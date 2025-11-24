# frozen_string_literal: true

# == Schema Information
#
# Table name: email_deliveries
#
#  id                                  :bigint           not null, primary key
#  mailer_action_name                  :string           default(""), not null
#  mailer_class_name                   :string           default(""), not null
#  subject                             :string           default(""), not null
#  to                                  :string           default(""), not null
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  application_form_id                 :bigint
#  further_information_request_id      :bigint
#  prioritisation_reference_request_id :bigint
#  reference_request_id                :bigint
#
# Indexes
#
#  index_email_deliveries_on_application_form_id                  (application_form_id)
#  index_email_deliveries_on_further_information_request_id       (further_information_request_id)
#  index_email_deliveries_on_prioritisation_reference_request_id  (prioritisation_reference_request_id)
#  index_email_deliveries_on_reference_request_id                 (reference_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#  fk_rails_...  (further_information_request_id => further_information_requests.id)
#  fk_rails_...  (prioritisation_reference_request_id => prioritisation_reference_requests.id)
#  fk_rails_...  (reference_request_id => reference_requests.id)
#
FactoryBot.define do
  factory :email_delivery do
    association :application_form

    to { Faker::Internet.email }
    subject { Faker::Lorem.sentence }
    mailer_class_name { "teacher_mailer" }
    mailer_action_name { "application_received" }
  end
end
