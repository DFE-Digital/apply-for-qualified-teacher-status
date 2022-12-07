# frozen_string_literal: true

module Devise::Models::OtpAuthenticatable
  extend ActiveSupport::Concern

  included { attr_reader :otp }

  def password_required?
    false
  end

  def password
    nil
  end

  def after_otp_authentication
    update!(secret_key: nil)
  end

  def after_failed_otp_authentication
    clear_otp_state
  end

  def after_successful_otp_authentication
    clear_otp_state
  end

  def clear_otp_state
    update!(secret_key: nil, otp_guesses: 0)
  end

  def create_otp
    secret_key = Devise::Otp.generate_key
    update!(secret_key:, otp_created_at: Time.zone.now)
  end
end
