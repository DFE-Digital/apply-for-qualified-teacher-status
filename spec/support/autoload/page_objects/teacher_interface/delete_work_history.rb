# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class DeleteWorkHistory < DeleteForm
      set_url "/teacher/application/work_histories/{work_history_id}/delete"
    end
  end
end
