module TeacherInterface
  class TeachChildrenController < BaseController
    def new
      @teach_children_form = TeachChildrenForm.new
    end

    def create
      eligibility_check = EligibilityCheck.find(session[:eligibility_check_id])
      @teach_children_form =
        TeachChildrenForm.new(
          teach_children_form_params.merge(eligibility_check:)
        )
      if @teach_children_form.save
        redirect_to(
          if @teach_children_form.teach_children
            teacher_interface_recognised_url
          else
            teacher_interface_ineligible_url
          end
        )
      else
        render :new
      end
    end

    private

    def teach_children_form_params
      params.require(:teach_children_form).permit(:teach_children)
    end
  end
end
