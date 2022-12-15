# frozen_string_literal: true

class SupportInterface::BaseController < ApplicationController
  include SupportCurrentNamespace

  before_action :authenticate_staff!, :authorize_support
  after_action :verify_authorized

  def authorize_support
    authorize :support
  end

  alias_method :pundit_user, :current_staff
end
