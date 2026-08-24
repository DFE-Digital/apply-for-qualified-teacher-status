# frozen_string_literal: true

class AssessorInterface::EmailDeliveryFailuresController < AssessorInterface::BaseController
  include HistoryTrackable

  define_history_origin :index
  define_history_reset :index

  def index
    authorize %i[assessor_interface email_delivery]

    @view_object =
      AssessorInterface::EmailDeliveryFailuresIndexViewObject.new(params:)

    render layout: "full_from_desktop"
  end
end
