# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class EditReferenceRequestReports < ReferenceRequestQuestionForm
      set_url "/teacher/references/{slug}/reports"
    end
  end
end
