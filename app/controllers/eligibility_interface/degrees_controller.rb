# frozen_string_literal: true

module EligibilityInterface
  class DegreesController < BaseController
    include EnforceEligibilityQuestionOrder

    def new
      @form = DegreeForm.new(degree: eligibility_check.degree)
    end

    def create
      @form = DegreeForm.new(form_params.merge(eligibility_check:))
      if @form.save
        redirect_to %i[eligibility_interface teach_children]
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def form_params
      params.require(:eligibility_interface_degree_form).permit(:degree)
    end
  end
end
