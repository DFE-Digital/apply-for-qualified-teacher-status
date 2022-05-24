module TeacherInterface
  class RecognisedController < BaseController
    def new
      @recognised_form = RecognisedForm.new
    end

    def create
      @recognised_form =
        RecognisedForm.new(recognised_form_params.merge(eligibility_check:))
      if @recognised_form.save
        redirect_to @recognised_form.success_url
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
