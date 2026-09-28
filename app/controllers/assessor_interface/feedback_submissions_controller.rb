# frozen_string_literal: true

class AssessorInterface::FeedbackSubmissionsController < AssessorInterface::BaseController
  before_action { authorize %i[assessor_interface service_level_agreement] }

  def index
    @view_object =
      AssessorInterface::FeedbackSubmissionsIndexViewObject.new(params:)

    render layout: "full_from_desktop"
  end
end
