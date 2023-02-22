# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class EditReferenceRequestContact < ReferenceRequestQuestionForm
      set_url "/teacher/references/{slug}/contact"
    end
  end
end
