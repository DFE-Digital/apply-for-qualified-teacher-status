# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class DeleteQualification < DeleteForm
      set_url "/teacher/application/qualifications/{qualification_id}/delete"
    end
  end
end
