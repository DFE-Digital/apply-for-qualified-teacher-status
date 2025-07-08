# frozen_string_literal: true

module TeacherInterface
  class PrioritisationReferenceRequestConfirmApplicantResponseForm < BaseForm
    attr_accessor :prioritisation_reference_request
    attribute :confirm_applicant_response, :boolean
    attribute :confirm_applicant_comment, :string

    validates :prioritisation_reference_request, presence: true
    validates :confirm_applicant_response, inclusion: [true, false]
    validates :confirm_applicant_comment,
              presence: true,
              if: -> { confirm_applicant_response == false }

    def update_model
      prioritisation_reference_request.update!(
        confirm_applicant_response:,
        confirm_applicant_comment:,
      )
    end
  end
end
