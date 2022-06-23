module SupportInterface
  class StaffController < BaseController
    def index
      @staff = Staff.all
    end
  end
end
