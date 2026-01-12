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
class SupportRequest < ApplicationRecord
  has_one_attached :screenshot, dependent: :purge_later

  enum :category_type,
       {
         applicantion_submitted: "applicantion_submitted",
         submitting_an_application: "submitting_an_application",
         providing_a_reference: "providing_a_reference",
         other: "other",
       },
       prefix: true

  enum :application_enquiry_type,
       { progress_update: "progress_update", other: "other" },
       prefix: true
end
