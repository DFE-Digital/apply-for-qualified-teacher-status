module PageObjects
  module TeacherInterface
    class EditQualification < QualificationsForm
      set_url "/teacher/application/qualifications/{qualification_id}/edit"
    end
  end
end
