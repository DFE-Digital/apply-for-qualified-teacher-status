class AssessorInterface::BaseController < ApplicationController
  include AssessorCurrentNamespace

  before_action :authenticate_staff!
end
