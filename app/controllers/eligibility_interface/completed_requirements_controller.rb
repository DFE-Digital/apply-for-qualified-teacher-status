module EligibilityInterface
  class CompletedRequirementsController < BaseController
    include EnforceEligibilityQuestionOrder

    def new
      @completed_requirements_form = CompletedRequirementsForm.new
    end

    def create
      @completed_requirements_form =
        CompletedRequirementsForm.new(
          completed_requirements_form_params.merge(eligibility_check:)
        )
      if @completed_requirements_form.save
        redirect_to @completed_requirements_form.success_url
      else
        render :new
      end
    end

    private

    def completed_requirements_form_params
      params.require(:eligibility_interface_completed_requirements_form).permit(
        :completed_requirements
      )
    end
  end
end
