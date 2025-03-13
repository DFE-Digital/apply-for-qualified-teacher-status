# frozen_string_literal: true

# == Schema Information
#
# Table name: mail_delivery_failures
#
#  id                   :bigint           not null, primary key
#  email_address        :string           not null
#  mailer_action_method :string           not null
#  mailer_class         :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_mail_delivery_failures_on_email_address  (email_address)
#

class MailDeliveryFailure < ApplicationRecord
end
