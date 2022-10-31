module EligibilityInterface
  class TeachChildrenController < BaseController
    include EnforceEligibilityQuestionOrder

    def new
      @teach_children_form =
        TeachChildrenForm.new(teach_children: eligibility_check.teach_children)
    end

    def create
      @teach_children_form =
        TeachChildrenForm.new(
          teach_children_form_params.merge(eligibility_check:),
        )
      if @teach_children_form.save
        redirect_to paths[:misconduct]
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def teach_children_form_params
      params.require(:eligibility_interface_teach_children_form).permit(
        :teach_children,
      )
    end
  end
end
