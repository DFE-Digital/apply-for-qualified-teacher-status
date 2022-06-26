class StaffHttpBasicAuthStrategy < Warden::Strategies::Base
  def valid?
    FeatureFlag.active?(:staff_http_basic_auth) || !Staff.exists?
  end

  def store?
    false
  end

  def authenticate!
    auth = Rack::Auth::Basic::Request.new(env)

    return success!(ANONYMOUS_SUPPORT_USER) if credentials_valid?(auth)

    custom!(
      [
        401,
        {
          "Content-Type" => "text/plain",
          "Content-Length" => "0",
          "WWW-Authenticate" => "Basic realm=\"Application\""
        },
        []
      ]
    )
  end

  private

  SUPPORT_USERNAME =
    Digest::SHA256.hexdigest(ENV.fetch("SUPPORT_USERNAME", "test"))
  SUPPORT_PASSWORD =
    Digest::SHA256.hexdigest(ENV.fetch("SUPPORT_PASSWORD", "test"))

  ANONYMOUS_SUPPORT_USER = AnonymousSupportUser.new

  def credentials_valid?(auth)
    return false unless auth.provided? && auth.basic? && auth.credentials

    valid_comparison?(SUPPORT_USERNAME, auth.credentials.first) &&
      valid_comparison?(SUPPORT_PASSWORD, auth.credentials.last)
  end

  def valid_comparison?(correct_value, given_value)
    ActiveSupport::SecurityUtils.secure_compare(
      Digest::SHA256.hexdigest(given_value),
      correct_value
    )
  end
end
