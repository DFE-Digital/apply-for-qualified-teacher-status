# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class DeleteOtherEnglandWorkHistory < DeleteForm
      set_url "/teacher/application/other_england_work_histories/{work_history_id}/delete"
    end
  end
end
