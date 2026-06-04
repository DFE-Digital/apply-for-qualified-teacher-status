# frozen_string_literal: true

module TeacherInterface
  class DeclarationDecisionReviewRequestForm < BaseForm
    attribute :confirm

    validates :confirm, presence: true

    private

    def update_model
      # No update required
    end
  end
end
