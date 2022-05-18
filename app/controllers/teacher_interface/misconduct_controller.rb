module TeacherInterface
  class MisconductController < BaseController
    def new
      @misconduct_form = MisconductForm.new
    end

    def create
      eligibility_check = EligibilityCheck.find(session[:eligibility_check_id])
      @misconduct_form =
        MisconductForm.new(misconduct_params.merge(eligibility_check:))
      if @misconduct_form.save
        redirect_to(
          if @misconduct_form.free_of_sanctions
            teacher_interface_eligible_url
          else
            teacher_interface_ineligible_url
          end
        )
      else
        render :new
      end
    end

    private

    def misconduct_params
      params.require(:misconduct_form).permit(:free_of_sanctions)
    end
  end
end
