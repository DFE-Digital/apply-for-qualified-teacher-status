module EligibilityInterface
  class MisconductController < BaseController
    include EnforceEligibilityQuestionOrder

    def new
      @misconduct_form =
        MisconductForm.new(
          misconduct:
            (
              if eligibility_check.free_of_sanctions.nil?
                nil
              else
                !eligibility_check.free_of_sanctions
              end
            ),
        )
    end

    def create
      @misconduct_form =
        MisconductForm.new(misconduct_params.merge(eligibility_check:))
      if @misconduct_form.save
        redirect_to eligibility_interface_result_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def misconduct_params
      params.require(:eligibility_interface_misconduct_form).permit(:misconduct)
    end
  end
end
