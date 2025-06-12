# frozen_string_literal: true

module TeacherInterface
  class AddAnotherOtherEnglandWorkHistoryForm < BaseForm
    attribute :add_another, :boolean
    validates :add_another, inclusion: { in: [true, false] }

    def update_model
    end
  end
end
