# frozen_string_literal: true

class AssessorInterface::BaseController < ApplicationController
  include AssessorCurrentNamespace
  include StaffAuthenticatable

  layout "two_thirds"

  after_action :verify_authorized

  def authorize_assessor
    authorize :assessor
  end
end
