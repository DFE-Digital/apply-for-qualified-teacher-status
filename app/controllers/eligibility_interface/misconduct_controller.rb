module EligibilityInterface
  class MisconductController < BaseController
    def new
      @misconduct_form = MisconductForm.new
    end

    def create
      @misconduct_form =
        MisconductForm.new(misconduct_params.merge(eligibility_check:))
      if @misconduct_form.save
        redirect_to @misconduct_form.success_url
      else
        render :new
      end
    end

    private

    def misconduct_params
      params.require(:eligibility_interface_misconduct_form).permit(:misconduct)
    end
  end
end
