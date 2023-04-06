# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class EditWorkHistorySchool < WorkHistorySchoolForm
      set_url "/teacher/application/new_regs/work_histories/{work_history_id}/school"
    end
  end
end
