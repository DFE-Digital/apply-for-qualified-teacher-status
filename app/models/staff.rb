# frozen_string_literal: true

# == Schema Information
#
# Table name: staff
#
#  id                             :bigint           not null, primary key
#  archived                       :boolean          default(FALSE)
#  assess_permission              :boolean          default(FALSE)
#  azure_ad_uid                   :string
#  change_email_permission        :boolean          default(FALSE), not null
#  change_name_permission         :boolean          default(FALSE), not null
#  change_work_history_permission :boolean          default(FALSE), not null
#  confirmation_sent_at           :datetime
#  confirmation_token             :string
#  confirmed_at                   :datetime
#  current_sign_in_at             :datetime
#  current_sign_in_ip             :string
#  email                          :string           default(""), not null
#  encrypted_password             :string           default(""), not null
#  failed_attempts                :integer          default(0), not null
#  invitation_accepted_at         :datetime
#  invitation_created_at          :datetime
#  invitation_limit               :integer
#  invitation_sent_at             :datetime
#  invitation_token               :string
#  invitations_count              :integer          default(0)
#  invited_by_type                :string
#  last_sign_in_at                :datetime
#  last_sign_in_ip                :string
#  locked_at                      :datetime
#  manage_staff_permission        :boolean          default(FALSE), not null
#  name                           :text             default(""), not null
#  remember_created_at            :datetime
#  reset_password_sent_at         :datetime
#  reset_password_token           :string
#  reverse_decision_permission    :boolean          default(FALSE), not null
#  sign_in_count                  :integer          default(0), not null
#  support_console_permission     :boolean          default(FALSE), not null
#  unconfirmed_email              :string
#  unlock_token                   :string
#  verify_permission              :boolean          default(FALSE), not null
#  withdraw_permission            :boolean          default(FALSE), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  invited_by_id                  :bigint
#
# Indexes
#
#  index_staff_on_confirmation_token    (confirmation_token) UNIQUE
#  index_staff_on_invitation_token      (invitation_token) UNIQUE
#  index_staff_on_invited_by            (invited_by_type,invited_by_id)
#  index_staff_on_invited_by_id         (invited_by_id)
#  index_staff_on_lower_email           (lower((email)::text)) UNIQUE
#  index_staff_on_reset_password_token  (reset_password_token) UNIQUE
#  index_staff_on_unlock_token          (unlock_token) UNIQUE
#
class Staff < ApplicationRecord
  include Emailable

  devise :database_authenticatable,
         :confirmable,
         :recoverable,
         :rememberable,
         :trackable,
         :timeoutable,
         :validatable,
         :lockable,
         :invitable,
         :omniauthable,
         omniauth_providers: [:entra_id]

  self.timeout_in = 20.minutes

  validates :name, presence: true

  scope :assessors, -> { where(assess_permission: true) }
  scope :not_archived, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
