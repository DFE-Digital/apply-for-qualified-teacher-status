# == Schema Information
#
# Table name: dqt_trn_requests
#
#  id                  :bigint           not null, primary key
#  state               :string           default("initial"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  application_form_id :bigint           not null
#  request_id          :uuid             not null
#
# Indexes
#
#  index_dqt_trn_requests_on_application_form_id  (application_form_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_form_id => application_forms.id)
#
FactoryBot.define do
  factory :dqt_trn_request do
    association :application_form, :submitted

    request_id { SecureRandom.uuid }
  end
end
