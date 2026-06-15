# frozen_string_literal: true

# == Schema Information
#
# Table name: email_deliveries
#
#  id                                  :bigint           not null, primary key
#  mailer_action_name                  :string           default(""), not null
#  mailer_class_name                   :string           default(""), not null
#  notify_completed_at                 :datetime
#  notify_status                       :string           default("created")
#  subject                             :string           default(""), not null
#  to                                  :string           default(""), not null
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  application_form_id                 :bigint
#  further_information_request_id      :bigint
#  notify_id                           :string
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

require "rails_helper"

RSpec.describe EmailDelivery, type: :model do
  describe ".failed" do
    subject(:failed) { described_class.failed }

    before do
      create(:email_delivery, to: "created@test.com", notify_status: :created)
      create(
        :email_delivery,
        to: "delivered@test.com",
        notify_status: :delivered,
      )
      create(
        :email_delivery,
        to: "permanent_failure@test.com",
        notify_status: :permanent_failure,
      )
      create(
        :email_delivery,
        to: "temporary_failure@test.com",
        notify_status: :temporary_failure,
      )
      create(
        :email_delivery,
        to: "technical_failure@test.com",
        notify_status: :technical_failure,
      )
    end

    it "returns all email deliveries with failure statuses" do
      expect(subject.pluck(:to)).to contain_exactly(
        "permanent_failure@test.com",
        "temporary_failure@test.com",
        "technical_failure@test.com",
      )
    end
  end
end
