# frozen_string_literal: true

class AssessorInterface::BaseController < ApplicationController
  include AssessorCurrentNamespace

  layout "two_thirds"

  before_action :authenticate_staff!
  after_action :verify_authorized

  def authorize_assessor
    authorize :assessor
  end

  def authorize_note
    authorize :note
  end

  alias_method :pundit_user, :current_staff
end
