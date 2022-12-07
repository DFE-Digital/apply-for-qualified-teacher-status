# frozen_string_literal: true

class Devise::Otp
  def self.valid?(secret_key, submitted_otp)
    submitted_otp == derive_otp(secret_key)
  end

  def self.derive_otp(key)
    otp_generator = ROTP::HOTP.new(key)
    otp_generator.at(0)
  end

  def self.generate_key
    ROTP::Base32.random
  end
end
