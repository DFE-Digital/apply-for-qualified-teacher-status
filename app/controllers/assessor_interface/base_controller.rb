# frozen_string_literal: true

class AssessorInterface::BaseController < ApplicationController
  include AssessorCurrentNamespace
  include HistoryTrackable
  include StaffAuthenticatable

  after_action :verify_authorized
end
