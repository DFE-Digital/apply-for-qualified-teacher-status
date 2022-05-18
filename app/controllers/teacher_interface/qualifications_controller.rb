module TeacherInterface
  class QualificationsController < BaseController
    def new
      @qualification_form = QualificationForm.new
    end

    def create
      eligibility_check = EligibilityCheck.find(session[:eligibility_check_id])
      @qualification_form =
        QualificationForm.new(
          qualification_form_params.merge(eligibility_check:)
        )
      if @qualification_form.save
        redirect_to @qualification_form.success_url
      else
        render :new
      end
    end

    private

    def qualification_form_params
      params.require(:qualification_form).permit
    end
  end
end
