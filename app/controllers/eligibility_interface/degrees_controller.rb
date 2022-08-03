module EligibilityInterface
  class DegreesController < BaseController
    include EnforceEligibilityQuestionOrder

    def new
      @degree_form = DegreeForm.new
    end

    def create
      @degree_form =
        DegreeForm.new(degree_form_params.merge(eligibility_check:))
      if @degree_form.save
        redirect_to paths[:teach_children]
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def degree_form_params
      params.require(:eligibility_interface_degree_form).permit(:degree)
    end
  end
end
