module TeacherInterface
  class MisconductController < BaseController
    def new
      @misconduct_form = MisconductForm.new
    end

    def create
      eligibility_check = EligibilityCheck.new
      @misconduct_form = MisconductForm.new(misconduct_params.merge(eligibility_check:))
      if @misconduct_form.save
        session[:eligibility_check_id] = eligibility_check.id
        redirect_to teacher_interface_eligible_url
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
