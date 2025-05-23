# frozen_string_literal: true

module EligibilityInterface
  class MisconductController < BaseController
    include EnforceEligibilityQuestionOrder

    def new
      @form =
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
      @form = MisconductForm.new(form_params.merge(eligibility_check:))
      if @form.save
        redirect_to %i[eligibility_interface teach_children]
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def form_params
      params.require(:eligibility_interface_misconduct_form).permit(:misconduct)
    end
  end
end
