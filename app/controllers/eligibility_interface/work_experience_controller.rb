# frozen_string_literal: true

module EligibilityInterface
  class WorkExperienceController < BaseController
    include EnforceEligibilityQuestionOrder

    def new
      @work_experience_form =
        WorkExperienceForm.new(
          work_experience: eligibility_check.work_experience,
        )
    end

    def create
      @work_experience_form =
        WorkExperienceForm.new(
          work_experience_form_params.merge(eligibility_check:),
        )
      if @work_experience_form.save
        redirect_to eligibility_interface_misconduct_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def work_experience_form_params
      params.require(:eligibility_interface_work_experience_form).permit(
        :work_experience,
      )
    end
  end
end
