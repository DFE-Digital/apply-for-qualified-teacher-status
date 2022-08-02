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
    Digest::SHA256.hexdigest(ENV.fetch("SUPPORT_USERNAME", "support"))
  SUPPORT_PASSWORD =
    Digest::SHA256.hexdigest(ENV.fetch("SUPPORT_PASSWORD", "support"))

  TEST_USERNAME = Digest::SHA256.hexdigest(ENV.fetch("TEST_USERNAME", "test"))
  TEST_PASSWORD = Digest::SHA256.hexdigest(ENV.fetch("TEST_PASSWORD", "test"))

  ANONYMOUS_SUPPORT_USER = AnonymousSupportUser.new

  def valid_users
    users = [{ username: SUPPORT_USERNAME, password: SUPPORT_PASSWORD }]

    if FeatureFlag.active?(:staff_test_user)
      users.push({ username: TEST_USERNAME, password: TEST_PASSWORD })
    end
    users
  end

  def credentials_valid?(auth)
    return false unless auth.provided? && auth.basic? && auth.credentials

    valid_users.any? do |user|
      valid_comparison?(user[:username], auth.credentials.first) &&
        valid_comparison?(user[:password], auth.credentials.last)
    end
  end

  def valid_comparison?(correct_value, given_value)
    ActiveSupport::SecurityUtils.secure_compare(
      Digest::SHA256.hexdigest(given_value),
      correct_value
    )
  end
end
