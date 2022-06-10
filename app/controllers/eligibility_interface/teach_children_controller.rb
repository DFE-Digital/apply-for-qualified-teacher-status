module EligibilityInterface
  class TeachChildrenController < BaseController
    def new
      @teach_children_form = TeachChildrenForm.new
    end

    def create
      @teach_children_form =
        TeachChildrenForm.new(
          teach_children_form_params.merge(eligibility_check:)
        )
      if @teach_children_form.save
        redirect_to @teach_children_form.success_url
      else
        render :new
      end
    end

    private

    def teach_children_form_params
      params.require(:eligibility_interface_teach_children_form).permit(
        :teach_children
      )
    end
  end
end
