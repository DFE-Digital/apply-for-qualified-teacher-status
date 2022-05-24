module TeacherInterface
  class CountriesController < BaseController
    def new
      @recognised_form = RecognisedForm.new
    end

    def create
      eligibility_check = EligibilityCheck.new
      @recognised_form =
        RecognisedForm.new(recognised_form_params.merge(eligibility_check:))
      if @recognised_form.save
        session[:eligibility_check_id] = eligibility_check.id
        redirect_to(
          if @recognised_form.recognised
            teacher_interface_misconduct_url
          else
            teacher_interface_ineligible_url
          end
        )
      else
        render :new
      end
    end

    private

    def recognised_form_params
      params.require(:recognised_form).permit(:recognised)
    end
  end
end
