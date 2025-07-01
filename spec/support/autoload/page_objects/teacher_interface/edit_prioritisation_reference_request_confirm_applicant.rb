# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class EditPrioritisationReferenceRequestConfirmApplicant < ReferenceRequestQuestionForm
      set_url "/teacher/prioritisation-references/{slug}/confirm-applicant"
    end
  end
end
