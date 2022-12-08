# == Schema Information
#
# Table name: teachers
#
#  id                 :bigint           not null, primary key
#  current_sign_in_at :datetime
#  current_sign_in_ip :string
#  email              :string           default(""), not null
#  last_sign_in_at    :datetime
#  last_sign_in_ip    :string
#  otp_created_at     :datetime
#  otp_guesses        :integer          default(0), not null
#  secret_key         :string
#  sign_in_count      :integer          default(0), not null
#  trn                :string
#  uuid               :uuid             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_teachers_on_email  (email) UNIQUE
#  index_teachers_on_uuid   (uuid) UNIQUE
#
class Teacher < ApplicationRecord
  devise :registerable, :timeoutable, :trackable
  include Devise::Models::OtpAuthenticatable

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

  def send_otp(*)
    otp = Devise::Otp.derive_otp(secret_key)
    send_devise_notification(:otp, otp)
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
