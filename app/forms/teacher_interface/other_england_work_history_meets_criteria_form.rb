# frozen_string_literal: true

module TeacherInterface
  class OtherEnglandWorkHistoryMeetsCriteriaForm < BaseForm
    attr_accessor :application_form
    attribute :has_other_england_work_history, :boolean

    validates :application_form, presence: true
    validates :has_other_england_work_history, inclusion: [true, false]

    def update_model
      application_form.update!(has_other_england_work_history:)
    end
  end
end
