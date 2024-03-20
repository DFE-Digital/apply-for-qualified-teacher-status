# frozen_string_literal: true

class StaticController < ApplicationController
  include EligibilityCurrentNamespace

  def email
    address = I18n.t(params[:key], scope: %i[service email])
    redirect_to "mailto:#{address}", allow_other_host: true
  end
end
