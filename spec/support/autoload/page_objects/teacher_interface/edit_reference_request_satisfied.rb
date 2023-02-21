# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class EditReferenceRequestSatisfied < ReferenceRequestQuestionForm
      set_url "/teacher/references/{slug}/satisfied"
    end
  end
end
