# frozen_string_literal: true

module EligibilityInterface
  class WorkExperienceRefereeController < BaseController
    include EnforceEligibilityQuestionOrder

    def new
      @form =
        WorkExperienceRefereeForm.new(
          eligibility_check: eligibility_check,
          work_experience_referee: eligibility_check.work_experience_referee,
        )
    end

    def create
      @form =
        WorkExperienceRefereeForm.new(form_params.merge(eligibility_check:))
      if @form.save
        redirect_to %i[eligibility_interface misconduct]
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def form_params
      params.require(
        :eligibility_interface_work_experience_referee_form,
      ).permit(:work_experience_referee)
    end
  end
end
