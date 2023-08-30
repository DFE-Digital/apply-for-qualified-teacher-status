# frozen_string_literal: true

class SupportInterface::BaseController < ApplicationController
  include SupportCurrentNamespace
  include StaffAuthenticatable

  after_action :verify_authorized
end
