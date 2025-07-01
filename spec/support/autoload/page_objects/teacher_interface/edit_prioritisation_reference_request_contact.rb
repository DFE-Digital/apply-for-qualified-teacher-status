# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class EditPrioritisationReferenceRequestContact < ReferenceRequestQuestionForm
      set_url "/teacher/prioritisation-references/{slug}/contact"
    end
  end
end
