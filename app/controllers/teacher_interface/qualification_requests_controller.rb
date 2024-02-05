# frozen_string_literal: true

module TeacherInterface
  class QualificationRequestsController < BaseController
    include HistoryTrackable

    define_history_origin :index
    define_history_reset :index

    def index
    end
  end
end
