# frozen_string_literal: true

module TeacherInterface
  class HasWorkHistoryForm < BaseForm
    attr_accessor :application_form
    attribute :has_work_history, :boolean

    validates :application_form, presence: true
    validates :has_work_history, inclusion: { in: [true, false] }

    def update_model
      application_form.update!(has_work_history:)
    end
  end
end
