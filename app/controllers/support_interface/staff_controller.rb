# frozen_string_literal: true

class SupportInterface::StaffController < SupportInterface::BaseController
  def index
    @staff = Staff.all
  end
end
