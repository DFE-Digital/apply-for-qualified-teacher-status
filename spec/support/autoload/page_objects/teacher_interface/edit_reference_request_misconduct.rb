# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class EditReferenceRequestMisconduct < ReferenceRequestQuestionForm
      set_url "/teacher/references/{slug}/misconduct"
    end
  end
end
