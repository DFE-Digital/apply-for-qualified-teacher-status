# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class EditReferenceRequestLessons < ReferenceRequestQuestionForm
      set_url "/teacher/references/{slug}/lessons"
    end
  end
end
