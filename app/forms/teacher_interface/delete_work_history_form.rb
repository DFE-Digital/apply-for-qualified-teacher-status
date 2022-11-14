# frozen_string_literal: true

module TeacherInterface
  class DeleteWorkHistoryForm < BaseForm
    attribute :confirm, :boolean
    attr_accessor :work_history

    validates :confirm, inclusion: { in: [true, false] }
    validates :work_history, presence: true, if: :confirm

    def update_model
      work_history.destroy! if confirm
    end
  end
end
