# frozen_string_literal: true

# == Schema Information
#
# Table name: reminder_emails
#
#  id                             :bigint           not null, primary key
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  further_information_request_id :bigint           not null
#
# Indexes
#
#  index_reminder_emails_on_further_information_request_id  (further_information_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (further_information_request_id => further_information_requests.id)
#
class ReminderEmail < ApplicationRecord
  belongs_to :further_information_request, inverse_of: :reminder_emails
end
