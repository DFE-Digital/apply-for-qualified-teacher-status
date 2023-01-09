# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class EditReferenceRequestHours < ReferenceRequestQuestionForm
      set_url "/teacher/references/{slug}/hours"
    end
  end
end
