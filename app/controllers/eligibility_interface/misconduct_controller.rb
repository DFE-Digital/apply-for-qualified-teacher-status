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
      params.require(:misconduct_form).permit(:free_of_sanctions)
    end
  end
end
