# frozen_string_literal: true

# == Schema Information
#
# Table name: support_requests
#
#  id                        :bigint           not null, primary key
#  application_reference     :string
#  comment                   :text
#  email                     :string
#  enquiry_type              :string
#  has_application_reference :boolean
#  name                      :string
#  submitted_at              :datetime
#  user_type                 :string
#  zendesk_ticket_created_at :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  zendesk_ticket_id         :string
#
class SupportRequest < ApplicationRecord
  has_one_attached :screenshot, dependent: :purge_later
end
