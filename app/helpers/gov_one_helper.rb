# frozen_string_literal: true

module GovOneHelper
  def logout_uri
    params = {
      post_logout_redirect_uri: destroy_teacher_session_url,
      id_token_hint: session[:id_token],
    }

    uri = URI.parse("#{Rails.configuration.gov_one.base_uri}logout")
    uri.query = URI.encode_www_form(params)

    uri.to_s
  end
end
