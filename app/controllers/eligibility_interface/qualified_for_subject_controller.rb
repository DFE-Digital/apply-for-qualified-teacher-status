# frozen_string_literal: true

module EligibilityInterface
  class QualifiedForSubjectController < BaseController
    include EnforceEligibilityQuestionOrder

    def new
      @form =
        QualifiedForSubjectForm.new(
          qualified_for_subject: eligibility_check.qualified_for_subject,
        )
    end

    def create
      @form = QualifiedForSubjectForm.new(form_params.merge(eligibility_check:))
      if @form.save
        redirect_to %i[eligibility_interface work_experience]
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def form_params
      params.require(:eligibility_interface_qualified_for_subject_form).permit(
        :qualified_for_subject,
      )
    end
  end
end
