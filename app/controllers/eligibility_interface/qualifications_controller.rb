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
        redirect_to paths[:degree]
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
  end
end
