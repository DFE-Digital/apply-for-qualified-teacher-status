# frozen_string_literal: true

module EligibilityInterface
  class WorkExperienceController < BaseController
    include EnforceEligibilityQuestionOrder

    def new
      @form =
        WorkExperienceForm.new(
          work_experience: eligibility_check.work_experience,
        )
    end

    def create
      @form = WorkExperienceForm.new(form_params.merge(eligibility_check:))
      if @form.save
        redirect_to %i[eligibility_interface misconduct]
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def form_params
      params.require(:eligibility_interface_work_experience_form).permit(
        :work_experience,
      )
    end
  end
end
