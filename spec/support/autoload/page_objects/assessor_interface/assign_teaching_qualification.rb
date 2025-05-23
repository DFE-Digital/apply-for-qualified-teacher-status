# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class AssignTeachingQualification < SitePrism::Page
      set_url "/assessor/applications/{reference}/qualifications/{qualification_id}/assign-teaching"

      element :heading, "h1"

      element :confirm_button, "button"
    end
  end
end
