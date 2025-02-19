# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Configure parameters to be filtered from the log file. Use this to limit dissemination of
# sensitive information. See the ActiveSupport::ParameterFilter documentation for supported
# notations and behaviors.
Rails.application.config.filter_parameters += %i[
  passw
  secret
  token
  confirmation_token
  _key
  crypt
  salt
  certificate
  ssn
  email
  given_names
  family_name
  date_of_birth
  alternative_given_names
  alternative_family_name
  registration_number
  trn
  unconfirmed_email
  current_sign_in_ip
  last_sign_in_ip
  _form
  _feedback
  _note
  _text
  _response
  _comment
]

Rails.application.config.filter_redirect << %r{/teacher/check_email}
