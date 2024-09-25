# frozen_string_literal: true

OmniAuth.config.allowed_request_methods = %i[post get]
OmniAuth.config.silence_get_warning = true

# We had to place the GovOne OmniAuth setup in this way
# since devise does not allow multi model omniauth by default.
# Source: https://github.com/heartcombo/devise/wiki/OmniAuth-with-multiple-models
#
# This configuration ensures that a POST request to /teacher/auth/gov_one
# redirects the user to Gov One authorization endpoint and on success returns
# them back to our callback URL with all auth details accessible via request.env["omniauth.auth"]
# inside the controller action (teachers/omniauth_callbacks#gov_one).
onelogin_sign_in_issuer_uri =
  if Rails.configuration.gov_one.base_uri.present?
    URI(Rails.configuration.gov_one.base_uri)
  end

callback_path = "/teacher/auth/gov_one/callback"

jwks_uri =
  if onelogin_sign_in_issuer_uri.present?
    "#{onelogin_sign_in_issuer_uri&.to_s}.well-known/jwks.json"
  end

gov_one_redirect_uri =
  if HostingEnvironment.development?
    "http://localhost:3000#{callback_path}"
  else
    "https://#{HostingEnvironment.host}#{callback_path}"
  end

end_session_endpoint =
  (
    if onelogin_sign_in_issuer_uri.present?
      "#{onelogin_sign_in_issuer_uri&.to_s}logout"
    end
  )

client_secret =
  if Rails.configuration.gov_one.base_62_private_key.present? &&
       !Rails.env.test?
    OpenSSL::PKey::RSA.new(
      Base64.decode64(Rails.configuration.gov_one.base_62_private_key),
    )
  end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect,
           {
             name: :gov_one,
             callback_path:,
             scope: %i[openid email],
             response_type: :code,
             issuer: onelogin_sign_in_issuer_uri&.to_s,
             path_prefix: "/teacher/auth",
             client_auth_method: "jwt_bearer",
             client_options: {
               port: nil,
               scheme: "https",
               host: onelogin_sign_in_issuer_uri&.host,
               identifier: Rails.configuration.gov_one.client_id,
               secret: client_secret,
               redirect_uri: gov_one_redirect_uri,
               authorization_endpoint: "/authorize",
               jwks_uri:,
               userinfo_endpoint: "/userinfo",
               end_session_endpoint:,
             },
           }

  on_failure do |env|
    Teachers::OmniauthCallbacksController.action(:failure).call(env)
  end
end
