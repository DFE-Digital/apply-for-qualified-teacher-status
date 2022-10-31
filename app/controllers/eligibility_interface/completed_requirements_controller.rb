module EligibilityInterface
  class CompletedRequirementsController < BaseController
    include EnforceEligibilityQuestionOrder

    def new
      @completed_requirements_form =
        CompletedRequirementsForm.new(eligibility_check.completed_requirements)
    end

    def create
      @completed_requirements_form =
        CompletedRequirementsForm.new(
          completed_requirements_form_params.merge(eligibility_check:),
        )
      if @completed_requirements_form.save
        redirect_to paths[:qualification]
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def completed_requirements_form_params
      params.require(:eligibility_interface_completed_requirements_form).permit(
        :completed_requirements,
      )
    end
  end
end
