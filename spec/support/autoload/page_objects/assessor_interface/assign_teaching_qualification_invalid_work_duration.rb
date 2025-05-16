# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class AssignTeachingQualificationInvalidWorkDuration < SitePrism::Page
      set_url "/assessor/applications/{reference}/qualifications/{qualification_id}/invalid-work-duration"

      element :heading, "h1"

      element :go_back_link, "a"
    end
  end
end
