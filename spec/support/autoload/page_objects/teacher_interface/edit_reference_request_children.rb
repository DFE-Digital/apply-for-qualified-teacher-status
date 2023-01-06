# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class EditReferenceRequestChildren < ReferenceRequestQuestionForm
      set_url "/teacher/references/{slug}/children"
    end
  end
end
