# frozen_string_literal: true

class SupportInterface::BaseController < ApplicationController
  include SupportCurrentNamespace
  include StaffAuthenticatable

  before_action :authorize_support
  after_action :verify_authorized

  def authorize_support
    authorize :support
  end
end
