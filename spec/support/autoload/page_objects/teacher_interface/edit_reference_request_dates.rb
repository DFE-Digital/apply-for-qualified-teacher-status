# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class EditReferenceRequestDates < ReferenceRequestQuestionForm
      set_url "/teacher/references/{slug}/dates"
    end
  end
end
