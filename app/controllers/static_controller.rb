# frozen_string_literal: true

class StaticController < ApplicationController
  include EligibilityCurrentNamespace

  EMAIL_KEYS = %w[enquiries verification].freeze

  def email
    key = params[:key]

    return head :not_found unless EMAIL_KEYS.include?(key)

    address = I18n.t(key, scope: %i[service email])
    redirect_to "mailto:#{address}", allow_other_host: true
  end
end
