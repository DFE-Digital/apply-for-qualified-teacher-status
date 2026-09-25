# frozen_string_literal: true

class AssessorInterface::FeedbackSubmissionsController < AssessorInterface::BaseController
  before_action { authorize %i[assessor_interface service_level_agreement] }

  def index
  end
end
