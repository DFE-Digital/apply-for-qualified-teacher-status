# frozen_string_literal: true

class SupportInterface::StaffController < SupportInterface::BaseController
  before_action :authorize_support

  def index
    @staff = Staff.all
  end
end
