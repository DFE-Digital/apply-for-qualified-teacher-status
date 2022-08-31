class AssessorInterface::BaseController < ApplicationController
  include AssessorCurrentNamespace

  layout "two_thirds"

  before_action :authenticate_staff!
end
