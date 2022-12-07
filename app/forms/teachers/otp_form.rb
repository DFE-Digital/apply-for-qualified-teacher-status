# frozen_string_literal: true

class Teachers::OtpForm
  MAX_GUESSES = 5
  EXPIRY_IN_MINUTES = 15.minutes

  include ActiveModel::Model

  attr_accessor :otp, :uuid
  attr_writer :email

  validates :otp, presence: true, length: { is: 6, allow_blank: true }
  validate :must_be_expected_otp

  def must_be_expected_otp
    return unless secret_key?

    expected_otp = Devise::Otp.derive_otp(teacher.secret_key)

    if otp != expected_otp
      errors.add(:otp, "Enter a correct security code")
      teacher.increment!(:otp_guesses)
    end
  end

  def otp_expired?
    teacher&.otp_created_at.blank? ||
      (EXPIRY_IN_MINUTES.ago >= teacher&.otp_created_at)
  end

  def secret_key?
    teacher.secret_key.present?
  end

  def maximum_guesses?
    teacher.otp_guesses >= MAX_GUESSES
  end

  def teacher
    @teacher ||= Teacher.find_by(uuid:)
  end

  def email
    @email ||= teacher&.email
  end
end
