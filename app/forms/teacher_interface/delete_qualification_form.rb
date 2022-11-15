# frozen_string_literal: true

module TeacherInterface
  class DeleteQualificationForm < BaseForm
    attribute :confirm, :boolean
    attr_accessor :qualification

    validates :confirm, inclusion: { in: [true, false] }
    validates :qualification, presence: true, if: :confirm

    def update_model
      qualification.destroy! if confirm
    end

    delegate :application_form, to: :qualification
  end
end
