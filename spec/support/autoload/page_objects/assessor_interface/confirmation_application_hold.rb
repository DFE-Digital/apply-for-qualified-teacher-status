# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ConfirmationApplicationHold < SitePrism::Page
      set_url "/assessor/applications/{reference}/application-holds/{application_hold_id}/confirmation"
    end
  end
end
