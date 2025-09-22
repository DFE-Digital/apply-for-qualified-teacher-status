# frozen_string_literal: true

class AssessorInterface::ServiceLevelAgreementsController < AssessorInterface::BaseController
  def index
    authorize %i[assessor_interface service_level_agreement]

    @view_object =
      AssessorInterface::ServiceLevelAgreementIndexViewObject.new(params:)

    render layout: "full_from_desktop"
  end
end
