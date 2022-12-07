# == Schema Information
#
# Table name: teachers
#
#  id                   :bigint           not null, primary key
#  confirmation_sent_at :datetime
#  confirmation_token   :string
#  confirmed_at         :datetime
#  current_sign_in_at   :datetime
#  current_sign_in_ip   :string
#  email                :string           default(""), not null
#  last_sign_in_at      :datetime
#  last_sign_in_ip      :string
#  otp_created_at       :datetime
#  otp_guesses          :integer          default(0), not null
#  secret_key           :string
#  sign_in_count        :integer          default(0), not null
#  trn                  :string
#  unconfirmed_email    :string
#  uuid                 :uuid             not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_teachers_on_email  (email) UNIQUE
#  index_teachers_on_uuid   (uuid) UNIQUE
#
class Teacher < ApplicationRecord
  devise :magic_link_authenticatable,
         :confirmable,
         :registerable,
         :timeoutable,
         :trackable

  self.timeout_in = 1.hour

  has_one :application_form

  validates :email,
            presence: true,
            uniqueness: {
              allow_blank: true,
              case_sensitive: true,
              if: :will_save_change_to_email?,
            },
            valid_for_notify: true

  def send_magic_link(*)
    token = Devise::Passwordless::LoginToken.encode(self)
    send_devise_notification(:magic_link, token, {})
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
