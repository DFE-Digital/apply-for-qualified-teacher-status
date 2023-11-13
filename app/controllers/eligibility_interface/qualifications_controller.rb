module EligibilityInterface
  class QualificationsController < BaseController
    include EnforceEligibilityQuestionOrder

    def new
      @qualification_form =
        QualificationForm.new(qualification: eligibility_check.qualification)
    end

    def create
      @qualification_form =
        QualificationForm.new(
          qualification_form_params.merge(eligibility_check:),
        )
      if @qualification_form.save
        redirect_to next_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def qualification_form_params
      params.require(:eligibility_interface_qualification_form).permit(
        :qualification,
      )
    end

    def next_path
      if eligibility_check.skip_additional_questions? &&
           eligibility_check.eligible?
        eligibility_interface_eligible_path
      else
        eligibility_interface_degree_path
      end
    end
  end
end
