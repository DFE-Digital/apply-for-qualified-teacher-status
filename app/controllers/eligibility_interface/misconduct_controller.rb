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
        redirect_to next_url
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def next_url
      if eligibility_check.eligible?
        eligibility_interface_eligible_path
      else
        eligibility_interface_ineligible_path
      end
    end

    def misconduct_params
      params.require(:eligibility_interface_misconduct_form).permit(:misconduct)
    end
  end
end
