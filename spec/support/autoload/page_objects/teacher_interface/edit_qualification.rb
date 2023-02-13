# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class EditQualification < QualificationForm
      set_url "/teacher/application/qualifications/{qualification_id}/edit"
    end
  end
end
