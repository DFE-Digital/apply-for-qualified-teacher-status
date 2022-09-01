class SupportInterface::BaseController < ApplicationController
  include SupportCurrentNamespace

  before_action :authenticate_staff!
end
