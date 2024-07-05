# == Schema Information
#
# Table name: mail_delivery_failures
#
#  id                   :bigint           not null, primary key
#  email_address        :string
#  mailer_action_method :string
#  mailer_class         :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class MailDeliveryFailure < ApplicationRecord
end
