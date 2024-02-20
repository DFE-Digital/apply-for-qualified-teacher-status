# frozen_string_literal: true

class AssessorInterface::BaseController < ApplicationController
  include AssessorCurrentNamespace
  include StaffAuthenticatable

  after_action :verify_authorized
end
