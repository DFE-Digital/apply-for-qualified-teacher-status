# frozen_string_literal: true

# == Schema Information
#
# Table name: reminder_emails
#
#  id               :bigint           not null, primary key
#  requestable_type :string           default(""), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  requestable_id   :bigint           not null
#
# Indexes
#
#  index_reminder_emails_on_requestable_type_and_requestable_id  (requestable_type,requestable_id)
#
class ReminderEmail < ApplicationRecord
  belongs_to :requestable, inverse_of: :reminder_emails, polymorphic: true
end
