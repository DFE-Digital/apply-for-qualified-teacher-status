# frozen_string_literal: true

# == Schema Information
#
# Table name: reminder_emails
#
#  id              :bigint           not null, primary key
#  name            :string           default("expiration"), not null
#  remindable_type :string           default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  remindable_id   :bigint           not null
#
# Indexes
#
#  index_reminder_emails_on_remindable_type_and_remindable_id  (remindable_type,remindable_id)
#
class ReminderEmail < ApplicationRecord
  belongs_to :remindable, inverse_of: :reminder_emails, polymorphic: true
end
