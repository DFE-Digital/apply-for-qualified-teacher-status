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
#  index_teacher_on_lower_email  (lower((email)::text)) UNIQUE
#  index_teachers_on_uuid        (uuid) UNIQUE
#
class Teacher < ApplicationRecord
  include Emailable

  devise :registerable, :timeoutable, :trackable
  include Devise::Models::OtpAuthenticatable

  self.timeout_in = 1.hour

  has_many :application_forms

  scope :with_draft_application_forms,
        -> {
          joins(:application_forms).where(
            application_forms: {
              status: "draft",
            },
          )
        }

  def application_form
    @application_form ||= application_forms.order(created_at: :desc).first
  end

  def send_otp(*)
    otp = Devise::Otp.derive_otp(secret_key)
    send_devise_notification(:otp, otp)
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
