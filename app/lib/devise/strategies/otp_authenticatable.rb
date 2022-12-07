# frozen_string_literal: true

require "devise"
require "devise/strategies/authenticatable"

class Devise::Strategies::OtpAuthenticatable < Devise::Strategies::Authenticatable
  #undef :password
  #undef :password=

  attr_accessor :otp, :email

  def valid_for_http_auth?
    super && http_auth_hash[:otp].present?
  end

  def valid_for_params_auth?
    super && params_auth_hash[:otp].present?
  end

  def authenticate!
    resource = mapping.to.find_by(email:)

    if secret_key_absent?(resource) || otp_invalid?(resource)
      fail!(:otp_invalid)
    elsif validate(resource)
      remember_me(resource)
      resource.after_otp_authentication
      success!(resource)
    else
      fail!(:otp_invalid)
    end
  end

  private

  def with_authentication_hash(auth_type, auth_values)
    self.authentication_hash = {}
    self.authentication_type = auth_type
    self.email = auth_values[:email]
    self.otp = auth_values[:otp]

    parse_authentication_key_values(auth_values, authentication_keys) &&
      parse_authentication_key_values(request_values, request_keys)
  end

  def secret_key_absent?(resource)
    resource&.secret_key.blank?
  end

  def otp_invalid?(resource)
    !Devise::Otp.valid?(resource.secret_key, otp)
  end
end
