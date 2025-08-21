# frozen_string_literal: true

module EligibilityInterface
  class WorkExperienceInEnglandController < BaseController
    include EnforceEligibilityQuestionOrder

    def new
      @form =
        WorkExperienceInEnglandForm.new(
          eligibility_check: eligibility_check,
          eligible: eligibility_check.eligible_work_experience_in_england,
        )
    end

    def create
      @form =
        WorkExperienceInEnglandForm.new(form_params.merge(eligibility_check:))
      if @form.save
        redirect_to %i[eligibility_interface teach_children]
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def form_params
      params.require(
        :eligibility_interface_work_experience_in_england_form,
      ).permit(:eligible)
    end
  end
end
